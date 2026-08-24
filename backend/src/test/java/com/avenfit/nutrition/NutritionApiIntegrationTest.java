package com.avenfit.nutrition;

import com.avenfit.auth.entity.User;
import com.avenfit.auth.repository.UserRepository;
import com.avenfit.auth.service.JwtService;
import com.avenfit.nutrition.entity.FoodItem;
import com.avenfit.nutrition.repository.FoodItemRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class NutritionApiIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private FoodItemRepository foodItemRepository;

    private User userA;
    private User userB;
    private String tokenA;
    private String tokenB;

    private FoodItem dalTadka;      // 128 kcal / 5.5P / 15C / 4.8F per katori
    private FoodItem roti;          // 104 / 3.2 / 20 / 1.5 per roti
    private FoodItem chickenCurry;  // non-veg marker for filters

    @BeforeAll
    void seed() {
        userA = user("NA");
        userB = user("NB");
        tokenA = jwtService.generateAccessToken(userA);
        tokenB = jwtService.generateAccessToken(userB);

        dalTadka = food("Moong Dal Tadka " + UUID.randomUUID(), 150, "katori",
                new BigDecimal("128"), new BigDecimal("5.5"), new BigDecimal("15"),
                new BigDecimal("4.8"), true);
        roti = food("Roti Test Grain " + UUID.randomUUID(), 40, "roti",
                new BigDecimal("104"), new BigDecimal("3.2"), new BigDecimal("20"),
                new BigDecimal("1.5"), true);
        chickenCurry = food("Chicken Curry Test " + UUID.randomUUID(), 200, "katori",
                new BigDecimal("180"), new BigDecimal("16"), new BigDecimal("6"),
                new BigDecimal("10"), false);

        // Extra dal varieties so multi-hit searches have stable fixtures
        food("Toor Dal Probe " + UUID.randomUUID(), 150, "katori",
                new BigDecimal("118"), new BigDecimal("6"), new BigDecimal("15"),
                new BigDecimal("3"), true);
        food("Masoor Dal Probe " + UUID.randomUUID(), 150, "katori",
                new BigDecimal("108"), new BigDecimal("6"), new BigDecimal("14"),
                new BigDecimal("2"), true);
    }

    private User user(String tag) {
        User u = new User();
        u.setPhoneNumber("+9150000" + tag.hashCode() % 100000);
        if (userRepository.findByPhoneNumber(u.getPhoneNumber()).isPresent()) {
            u.setPhoneNumber("+9150001" + tag.hashCode() % 100000);
        }
        u.setDisplayName("User " + tag);
        return userRepository.save(u);
    }

    private FoodItem food(String name, int servingSize, String unit, BigDecimal cal,
                          BigDecimal protein, BigDecimal carbs, BigDecimal fat, boolean veg) {
        FoodItem f = new FoodItem();
        f.setName(name);
        f.setServingSize(new BigDecimal(servingSize));
        f.setServingUnit(unit);
        f.setCalories(cal);
        f.setProteinG(protein);
        f.setCarbsG(carbs);
        f.setFatG(fat);
        f.setIsVegetarian(veg);
        f.setIsVerified(true);
        return foodItemRepository.save(f);
    }

    // ------------------------------------------------------------------
    // Food item search & visibility
    // ------------------------------------------------------------------

    @Test
    void dalSearchReturnsMultipleVarietiesCaseInsensitive() throws Exception {
        MvcResult result = mockMvc.perform(get("/api/food-items/search")
                        .param("q", "DAL")
                        .param("size", "50")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.page").value(0))
                .andExpect(jsonPath("$.totalElements").isNumber())
                .andReturn();

        JsonNode data = objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
        List<String> names = new ArrayList<>();
        data.forEach(n -> names.add(n.path("name").asText()));

        assertThat(names).anyMatch(n -> n.startsWith("Moong Dal Tadka"));
        assertThat(names).anyMatch(n -> n.contains("Toor Dal Probe"));
        assertThat(names).anyMatch(n -> n.contains("Masoor Dal Probe"));
    }

    @Test
    void vegetarianFilterExcludesNonVeg() throws Exception {
        MvcResult result = mockMvc.perform(get("/api/food-items/search")
                        .param("q", "chicken curry test")
                        .param("vegetarian", "true")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();

        assertThat(objectMapper.readTree(result.getResponse().getContentAsString())
                .path("data")).isEmpty();
    }

    @Test
    void foreignCustomFoodHiddenFromOthersSearchAndGet() throws Exception {
        FoodItem bCustom = food("Secret B Food " + UUID.randomUUID(), 100, "g",
                new BigDecimal("200"), new BigDecimal("10"), new BigDecimal("20"),
                new BigDecimal("5"), true);
        bCustom.setIsCustom(true);
        bCustom.setCreatedBy(userB);
        foodItemRepository.save(bCustom);

        // Not in A's search results
        MvcResult search = mockMvc.perform(get("/api/food-items/search")
                        .param("q", "Secret B Food")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        assertThat(objectMapper.readTree(search.getResponse().getContentAsString())
                .path("data")).isEmpty();

        // And direct GET is 404 for A
        mockMvc.perform(get("/api/food-items/" + bCustom.getId())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNotFound());

        // But visible to B
        mockMvc.perform(get("/api/food-items/" + bCustom.getId())
                        .header("Authorization", "Bearer " + tokenB))
                .andExpect(status().isOk());
    }

    @Test
    void unknownFoodItemIs404() throws Exception {
        mockMvc.perform(get("/api/food-items/" + UUID.randomUUID())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNotFound());
    }

    @Test
    void createCustomFoodSucceedsAndAppearsInOwnSearch() throws Exception {
        String uniqueName = "Homely Khichdi " + UUID.randomUUID();
        MvcResult created = mockMvc.perform(post("/api/food-items")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"" + uniqueName + "\", \"servingSize\": 200, "
                                + "\"servingUnit\": \"katori\", \"calories\": 240, \"proteinG\": 8, "
                                + "\"carbsG\": 42, \"fatG\": 4, \"fiberG\": 3, \"isVegetarian\": true, "
                                + "\"foodCategory\": \"GRAIN\"}"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.isVerified").value(false))
                .andExpect(jsonPath("$.data.calories").value(240.0))
                .andReturn();

        String id = objectMapper.readTree(created.getResponse().getContentAsString())
                .path("data").path("id").asText();

        // Own search finds it; DTO shape omits isCustom by design
        mockMvc.perform(get("/api/food-items/search")
                        .param("q", uniqueName)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data[0].id").value(id));
    }

    @Test
    void negativeCaloriesRejectedWith400() throws Exception {
        mockMvc.perform(post("/api/food-items")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\": \"Bad Food\", \"servingSize\": 100, \"servingUnit\": \"g\", "
                                + "\"calories\": -5}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
    }

    // ------------------------------------------------------------------
    // Meal logging & daily summary
    // ------------------------------------------------------------------

    private JsonNode logMeal(String body, int expectedStatus) throws Exception {
        MvcResult result = mockMvc.perform(post("/api/nutrition/entries")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().is(expectedStatus))
                .andReturn();
        if (expectedStatus != 201) {
            return null;
        }
        return objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
    }

    @Test
    void logMealComputesMacrosFromFoodTimesQuantity() throws Exception {
        // Dal Tadka x2 => 256 kcal / 11P / 30C / 9.6F ; Roti x1.5 => 156 / 4.8 / 30 / 2.25
        JsonNode meal = logMeal("{\"mealType\": \"LUNCH\", " +
                "\"items\": [" +
                "{\"foodItemId\": \"" + dalTadka.getId() + "\", \"quantity\": 2}," +
                "{\"foodItemId\": \"" + roti.getId() + "\", \"quantity\": 1.5}]}", 201);

        assertThat(meal.path("items")).hasSize(2);

        JsonNode first = meal.path("items").get(0);
        assertThat(first.path("calories").asDouble()).isEqualTo(256.00);
        assertThat(first.path("proteinG").asDouble()).isEqualTo(11.00);
        assertThat(first.path("carbsG").asDouble()).isEqualTo(30.00);
        assertThat(first.path("fatG").asDouble()).isEqualTo(9.60);
        // Unit defaults to the food's own serving unit
        assertThat(first.path("servingUnit").asText()).isEqualTo("katori");

        JsonNode second = meal.path("items").get(1);
        assertThat(second.path("calories").asDouble()).isEqualTo(156.00);
        assertThat(second.path("servingUnit").asText()).isEqualTo("roti");

        assertThat(meal.path("totalCalories").asDouble()).isEqualTo(412.00);

        // Clean up so day-based assertions elsewhere stay predictable
        mockMvc.perform(delete("/api/nutrition/entries/" + meal.path("id").asText())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNoContent());
    }

    @Test
    void dailySummaryRespectsIstDayBoundary() throws Exception {
        // 2026-08-24T19:30Z == 2026-08-25T01:00 IST -> belongs to Aug 25 (IST)
        String utcInstant = "2026-08-24T19:30:00Z";
        JsonNode meal = logMeal("{\"mealType\": \"DINNER\", \"loggedAt\": \"" + utcInstant + "\", " +
                "\"items\": [{\"foodItemId\": \"" + dalTadka.getId() + "\", \"quantity\": 1}]}", 201);
        String entryId = meal.path("id").asText();

        String aug25 = mockMvc.perform(get("/api/nutrition/entries")
                        .param("date", "2026-08-25")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        JsonNode day25 = objectMapper.readTree(aug25).path("data");
        assertThat(day25.path("date").asText()).isEqualTo("2026-08-25");
        assertThat(day25.path("timezone").asText()).isEqualTo("Asia/Kolkata");
        assertThat(day25.path("meals").toString()).contains(entryId);
        assertThat(day25.path("totalCalories").asDouble()).isEqualTo(128.00);

        // The UTC calendar date must NOT contain it
        String aug24 = mockMvc.perform(get("/api/nutrition/entries")
                        .param("date", "2026-08-24")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        assertThat(objectMapper.readTree(aug24).path("data").path("meals").toString())
                .doesNotContain(entryId);

        mockMvc.perform(delete("/api/nutrition/entries/" + entryId)
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNoContent());
    }

    @Test
    void summaryTotalsSpanMultipleMeals() throws Exception {
        Instant now = Instant.now();
        JsonNode breakfast = logMeal("{\"mealType\": \"BREAKFAST\", \"loggedAt\": \"" + now + "\", " +
                "\"items\": [{\"foodItemId\": \"" + roti.getId() + "\", \"quantity\": 2}]}", 201);
        JsonNode snack = logMeal("{\"mealType\": \"SNACK\", \"loggedAt\": \"" + now.plusSeconds(60) + "\", " +
                "\"items\": [{\"foodItemId\": \"" + roti.getId() + "\", \"quantity\": 1}]}", 201);

        String today = java.time.LocalDate.now(java.time.ZoneId.of("Asia/Kolkata")).toString();
        JsonNode day = objectMapper.readTree(mockMvc.perform(get("/api/nutrition/entries")
                                .param("date", today)
                                .header("Authorization", "Bearer " + tokenA))
                        .andExpect(status().isOk())
                        .andReturn().getResponse().getContentAsString()).path("data");

        double expectedCalories = 208.00 + 104.00;
        assertThat(day.path("totalCalories").asDouble()).isGreaterThanOrEqualTo(expectedCalories - 0.01);
        assertThat(day.path("meals")).hasSizeGreaterThanOrEqualTo(2);

        mockMvc.perform(delete("/api/nutrition/entries/" + breakfast.path("id").asText())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNoContent());
        mockMvc.perform(delete("/api/nutrition/entries/" + snack.path("id").asText())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNoContent());
    }

    @Test
    void foreignEntryDeleteIs404() throws Exception {
        JsonNode meal = logMeal("{\"mealType\": \"SNACK\", \"items\": [" +
                "{\"foodItemId\": \"" + roti.getId() + "\", \"quantity\": 1}]}", 201);

        mockMvc.perform(delete("/api/nutrition/entries/" + meal.path("id").asText())
                        .header("Authorization", "Bearer " + tokenB))
                .andExpect(status().isNotFound());

        mockMvc.perform(delete("/api/nutrition/entries/" + meal.path("id").asText())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNoContent());
    }

    @Test
    void unknownFoodInMealReturns404() throws Exception {
        logMeal("{\"mealType\": \"LUNCH\", \"items\": [" +
                "{\"foodItemId\": \"" + UUID.randomUUID() + "\", \"quantity\": 1}]}", 404);
    }

    @Test
    void invalidMealTypeRejectedWith400() throws Exception {
        logMeal("{\"mealType\": \"BRUNCH\", \"items\": [" +
                "{\"foodItemId\": \"" + roti.getId() + "\", \"quantity\": 1}]}", 400);
    }
}
