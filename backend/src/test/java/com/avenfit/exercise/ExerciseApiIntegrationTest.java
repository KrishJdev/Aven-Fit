package com.avenfit.exercise;

import com.avenfit.auth.entity.User;
import com.avenfit.auth.repository.UserRepository;
import com.avenfit.auth.service.JwtService;
import com.avenfit.exercise.entity.Equipment;
import com.avenfit.exercise.entity.Exercise;
import com.avenfit.exercise.entity.ExerciseCategory;
import com.avenfit.exercise.entity.ExerciseMuscleGroup;
import com.avenfit.exercise.entity.MuscleGroup;
import com.avenfit.exercise.entity.MuscleRole;
import com.avenfit.exercise.repository.ExerciseRepository;
import com.avenfit.exercise.repository.MuscleGroupRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.transaction.Transactional;
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

import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class ExerciseApiIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private MuscleGroupRepository muscleGroupRepository;

    @Autowired
    private ExerciseRepository exerciseRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtService jwtService;

    private User userA;
    private User userB;
    private String tokenA;
    private String tokenB;

    private Exercise benchPress;
    private Exercise pushUp;
    private Exercise deadlift;
    private Exercise customByA;
    private Exercise customByB;

    private record Refs(MuscleGroup chest, MuscleGroup back, MuscleGroup shoulders,
                        MuscleGroup triceps, MuscleGroup hamstrings) {
    }

    private Refs refs;

    @BeforeAll
    @Transactional
    void seedReferenceData() {
        refs = new Refs(
                group("Chest", 1),
                group("Back", 2),
                group("Shoulders", 3),
                group("Triceps", 5),
                group("Hamstrings", 8)
        );
        // Fill remaining display slots so /api/muscle-groups can be asserted fully
        List<String> rest = List.of("Biceps", "Forearms", "Quadriceps", "Glutes", "Calves", "Abs", "Traps", "Lats", "Lower Back");
        List<Integer> orders = List.of(4, 6, 7, 9, 10, 11, 12, 13, 14);
        for (int i = 0; i < rest.size(); i++) {
            group(rest.get(i), orders.get(i));
        }

        userA = user("A");
        userB = user("B");
        tokenA = jwtService.generateAccessToken(userA);
        tokenB = jwtService.generateAccessToken(userB);

        benchPress = systemExercise(
                "Barbell Bench Press", ExerciseCategory.BARBELL, Equipment.BARBELL,
                new String[][]{{"Chest", "PRIMARY"}, {"Triceps", "SECONDARY"}, {"Shoulders", "SECONDARY"}});
        pushUp = systemExercise(
                "Push-Up", ExerciseCategory.BODYWEIGHT, Equipment.BODYWEIGHT,
                new String[][]{{"Chest", "PRIMARY"}});
        deadlift = systemExercise(
                "Deadlift", ExerciseCategory.BARBELL, Equipment.BARBELL,
                new String[][]{{"Back", "PRIMARY"}, {"Hamstrings", "SECONDARY"}});
        customByA = customExercise(userA, "My Landmine Press", ExerciseCategory.BARBELL, Equipment.BARBELL,
                new String[][]{{"Shoulders", "PRIMARY"}});
        customByB = customExercise(userB, "Secret B Move", ExerciseCategory.DUMBBELL, Equipment.DUMBBELL,
                new String[][]{{"Chest", "PRIMARY"}});
    }

    private MuscleGroup group(String name, int order) {
        MuscleGroup mg = new MuscleGroup();
        mg.setName(name);
        mg.setDisplayOrder(order);
        return muscleGroupRepository.save(mg);
    }

    private User user(String suffix) {
        User user = new User();
        user.setPhoneNumber("+91900000" + suffix.hashCode() % 100000);
        if (userRepository.findByPhoneNumber(user.getPhoneNumber()).isPresent()) {
            user.setPhoneNumber("+91900001" + suffix.hashCode() % 100000);
        }
        user.setDisplayName("User " + suffix);
        return userRepository.save(user);
    }

    private Exercise baseExercise(String name, ExerciseCategory category, Equipment equipment) {
        Exercise e = new Exercise();
        e.setName(name);
        e.setDescription(null);
        e.setCategory(category);
        e.setEquipment(equipment);
        return e;
    }

    private void addLink(Exercise e, String groupName, MuscleRole role) {
        MuscleGroup mg = refsByName(groupName);
        ExerciseMuscleGroup emg = new ExerciseMuscleGroup();
        emg.setExercise(e);
        emg.setMuscleGroup(mg);
        emg.setRole(role);
        e.getMuscleGroups().add(emg);
    }

    private MuscleGroup refsByName(String name) {
        return switch (name) {
            case "Chest" -> refs.chest();
            case "Back" -> refs.back();
            case "Shoulders" -> refs.shoulders();
            case "Triceps" -> refs.triceps();
            case "Hamstrings" -> refs.hamstrings();
            default -> throw new IllegalStateException(name);
        };
    }

    private Exercise systemExercise(String name, ExerciseCategory cat, Equipment eq, String[][] muscles) {
        Exercise e = baseExercise(name, cat, eq);
        e.setIsCustom(false);
        for (String[] m : muscles) {
            addLink(e, m[0], MuscleRole.valueOf(m[1]));
        }
        return exerciseRepository.save(e);
    }

    private Exercise customExercise(User owner, String name, ExerciseCategory cat, Equipment eq, String[][] muscles) {
        Exercise e = systemExercise(name, cat, eq, muscles);
        e.setIsCustom(true);
        e.setCreatedBy(owner);
        return exerciseRepository.save(e);
    }

    private MvcResult authorizedGet(String url, String token) throws Exception {
        return mockMvc.perform(get(url).header("Authorization", "Bearer " + token))
                .andReturn();
    }

    // ------------------------------------------------------------------
    // Listing & filtering (Task 3.1 acceptance criteria)
    // ------------------------------------------------------------------

    @Test
    void listReturnsSystemPlusOwnCustomAndExcludesOtherUsers() throws Exception {
        // Self-contained fixtures — other tests may have renamed/deleted shared ones
        Exercise aProbe = customExercise(userA, "Visibility Probe A", ExerciseCategory.MACHINE,
                Equipment.MACHINE, new String[][]{{"Chest", "PRIMARY"}});
        Exercise bProbe = customExercise(userB, "Visibility Probe B", ExerciseCategory.MACHINE,
                Equipment.MACHINE, new String[][]{{"Chest", "PRIMARY"}});

        MvcResult result = mockMvc.perform(get("/api/exercises").param("size", "100")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.page").value(0))
                .andExpect(jsonPath("$.size").value(100))
                .andExpect(jsonPath("$.totalElements").exists())
                .andExpect(jsonPath("$.totalPages").exists())
                .andReturn();
        JsonNode items = objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
        List<String> ids = new ArrayList<>();
        items.forEach(n -> ids.add(n.path("id").asText()));

        assertThat(ids).contains(aProbe.getId().toString(), benchPress.getId().toString());
        assertThat(ids).doesNotContain(bProbe.getId().toString());
    }

    @Test
    void searchIsCaseInsensitive() throws Exception {
        mockMvc.perform(get("/api/exercises")
                        .param("search", "bench")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(1))
                .andExpect(jsonPath("$.data[0].name").value("Barbell Bench Press"));
    }

    @Test
    void categoryFilterWorks() throws Exception {
        MvcResult result = mockMvc.perform(get("/api/exercises")
                        .param("category", "bodyweight") // case-insensitive parse
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode items = objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
        assertThat(items).isNotEmpty();
        items.forEach(n -> assertThat(n.path("category").asText()).isEqualTo("BODYWEIGHT"));
    }

    @Test
    void muscleGroupFilterWorks() throws Exception {
        MvcResult result = mockMvc.perform(get("/api/exercises")
                        .param("muscleGroup", "Hamstrings")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andReturn();
        JsonNode items = objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
        assertThat(items).hasSize(1);
        assertThat(items.get(0).path("name").asText()).isEqualTo("Deadlift");
    }

    @Test
    void combinedFiltersAndPaginationMetadataWork() throws Exception {
        mockMvc.perform(get("/api/exercises")
                        .param("search", "a")
                        .param("size", "2")
                        .param("page", "0")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.length()").value(2))
                .andExpect(jsonPath("$.size").value(2))
                .andExpect(jsonPath("$.totalElements").isNumber());
    }

    @Test
    void unknownCategoryIsRejectedWith400() throws Exception {
        mockMvc.perform(get("/api/exercises")
                        .param("category", "NOT_A_CATEGORY")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
    }

    @Test
    void oversizedPageIsRejectedWith400() throws Exception {
        mockMvc.perform(get("/api/exercises")
                        .param("size", "500")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isBadRequest());
    }

    // ------------------------------------------------------------------
    // Get by id & visibility rules
    // ------------------------------------------------------------------

    @Test
    void getReturnsExactDtoShapeWithPrimariesFirst() throws Exception {
        mockMvc.perform(get("/api/exercises/" + benchPress.getId())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.id").value(benchPress.getId().toString()))
                .andExpect(jsonPath("$.data.name").value("Barbell Bench Press"))
                .andExpect(jsonPath("$.data.category").value("BARBELL"))
                .andExpect(jsonPath("$.data.equipment").value("BARBELL"))
                .andExpect(jsonPath("$.data.isCustom").value(false))
                .andExpect(jsonPath("$.data.muscleGroups[0].name").value("Chest"))
                .andExpect(jsonPath("$.data.muscleGroups[0].role").value("PRIMARY"))
                .andExpect(jsonPath("$.data.muscleGroups.length()").value(3));
    }

    @Test
    void getAnotherUsersCustomExerciseReturns404() throws Exception {
        mockMvc.perform(get("/api/exercises/" + customByB.getId())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNotFound());
    }

    @Test
    void getUnknownExerciseReturns404() throws Exception {
        mockMvc.perform(get("/api/exercises/00000000-0000-4000-8000-000000000000")
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNotFound());
    }

    // ------------------------------------------------------------------
    // Create custom exercises
    // ------------------------------------------------------------------

    private String createBody(String name, String primaryId, String secondaryId) {
        StringBuilder sb = new StringBuilder();
        sb.append("{\"name\": \"").append(name).append("\", ")
                .append("\"description\": \"Created by integration test\", ")
                .append("\"category\": \"CABLE\", ")
                .append("\"equipment\": \"CABLE\", ")
                .append("\"primaryMuscleGroupIds\": [\"").append(primaryId).append("\"]");
        if (secondaryId != null) {
            sb.append(", \"secondaryMuscleGroupIds\": [\"").append(secondaryId).append("\"]");
        }
        sb.append("}");
        return sb.toString();
    }

    @Test
    @Transactional
    void createCustomExerciseSucceeds() throws Exception {
        MvcResult result = mockMvc.perform(post("/api/exercises")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody("Cable Crunch Variant", refs.back().getId().toString(),
                                refs.triceps().getId().toString())))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.data.isCustom").value(true))
                .andExpect(jsonPath("$.data.name").value("Cable Crunch Variant"))
                .andExpect(jsonPath("$.data.muscleGroups.length()").value(2))
                .andReturn();

        JsonNode dto = objectMapper.readTree(result.getResponse().getContentAsString()).path("data");
        // Reload and verify persistence of roles
        Exercise saved = exerciseRepository.findById(java.util.UUID.fromString(dto.path("id").asText())).orElseThrow();
        assertThat(saved.getCreatedBy().getId()).isEqualTo(userA.getId());
        assertThat(saved.getMuscleGroups()).extracting(ExerciseMuscleGroup::getRole)
                .containsExactlyInAnyOrder(MuscleRole.PRIMARY, MuscleRole.SECONDARY);
    }

    @Test
    void createWithUnknownMuscleGroupReturns404() throws Exception {
        mockMvc.perform(post("/api/exercises")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody("Ghost Press",
                                "00000000-0000-4000-8000-00000000beef", null)))
                .andExpect(status().isNotFound());
    }

    @Test
    void createWithOverlappingPrimarySecondaryRejected() throws Exception {
        mockMvc.perform(post("/api/exercises")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createBody("Overlap Press", refs.chest().getId().toString(),
                                refs.chest().getId().toString())))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
    }

    @Test
    void createWithoutPrimaryMuscleRejectedWith400() throws Exception {
        mockMvc.perform(post("/api/exercises")
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"name": "No Primary", "category": "OTHER", "equipment": "OTHER",
                                 "primaryMuscleGroupIds": []}
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("VALIDATION_ERROR"));
    }

    // ------------------------------------------------------------------
    // Update & delete ownership rules
    // ------------------------------------------------------------------

    private String updateBody(String name) {
        return "{\"name\": \"" + name + "\", \"description\": null, \"category\": \"CABLE\", "
                + "\"equipment\": \"CABLE\", "
                + "\"primaryMuscleGroupIds\": [\"" + refs.shoulders().getId() + "\"], "
                + "\"secondaryMuscleGroupIds\": []}";
    }

    @Test
    @Transactional
    void updateOwnCustomExerciseSucceeds() throws Exception {
        mockMvc.perform(put("/api/exercises/" + customByA.getId())
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(updateBody("Renamed Landmine Press")))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.name").value("Renamed Landmine Press"))
                .andExpect(jsonPath("$.data.muscleGroups.length()").value(1));

        Exercise reloaded = exerciseRepository.findById(customByA.getId()).orElseThrow();
        assertThat(reloaded.getName()).isEqualTo("Renamed Landmine Press");
        assertThat(reloaded.getMuscleGroups()).hasSize(1);
    }

    @Test
    @Transactional
    void updateSwappingRolesOnSameMuscleGroupsDoesNotViolateUniqueConstraint() throws Exception {
        // Regression: customByA starts with Shoulders as PRIMARY.
        // Step 1 adds Chest as PRIMARY and demotes Shoulders to SECONDARY
        // (same key changes role -> must UPDATE, never delete+reinsert).
        String demote = "{\"name\": \"My Landmine Press\", \"description\": null, "
                + "\"category\": \"BARBELL\", \"equipment\": \"BARBELL\", "
                + "\"primaryMuscleGroupIds\": [\"" + refs.chest().getId() + "\"], "
                + "\"secondaryMuscleGroupIds\": [\"" + refs.shoulders().getId() + "\"]}";

        mockMvc.perform(put("/api/exercises/" + customByA.getId())
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(demote))
                .andExpect(status().isOk());

        // Step 2 returns to the original shape (Shoulders PRIMARY again).
        String promote = "{\"name\": \"My Landmine Press\", \"description\": null, "
                + "\"category\": \"BARBELL\", \"equipment\": \"BARBELL\", "
                + "\"primaryMuscleGroupIds\": [\"" + refs.shoulders().getId() + "\"], "
                + "\"secondaryMuscleGroupIds\": []}";

        mockMvc.perform(put("/api/exercises/" + customByA.getId())
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(promote))
                .andExpect(status().isOk());

        Exercise reloaded = exerciseRepository.findById(customByA.getId()).orElseThrow();
        assertThat(reloaded.getMuscleGroups()).hasSize(1);
        assertThat(reloaded.getMuscleGroups().iterator().next().getRole()).isEqualTo(MuscleRole.PRIMARY);
        assertThat(reloaded.getMuscleGroups().iterator().next().getMuscleGroup().getName())
                .isEqualTo("Shoulders");
    }

    @Test
    void updateSystemExerciseReturns403() throws Exception {
        mockMvc.perform(put("/api/exercises/" + benchPress.getId())
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(updateBody("Hacked Bench")))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.error").value("FORBIDDEN"));
    }

    @Test
    void updateAnotherUsersCustomReturns403() throws Exception {
        mockMvc.perform(put("/api/exercises/" + customByB.getId())
                        .header("Authorization", "Bearer " + tokenA)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(updateBody("Stolen Move")))
                .andExpect(status().isForbidden());
    }

    @Test
    void deleteOwnCustomExerciseSucceeds() throws Exception {
        Exercise temp = customExercise(userA, "Temp Delete Me", ExerciseCategory.OTHER, Equipment.OTHER,
                new String[][]{{"Chest", "PRIMARY"}});

        mockMvc.perform(delete("/api/exercises/" + temp.getId())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isNoContent());

        assertThat(exerciseRepository.findById(temp.getId())).isEmpty();
    }

    @Test
    void deleteSystemExerciseReturns403() throws Exception {
        mockMvc.perform(delete("/api/exercises/" + benchPress.getId())
                        .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isForbidden());
    }

    @Test
    void deleteAnotherUsersCustomReturns403() throws Exception {
        mockMvc.perform(delete("/api/exercises/" + customByB.getId())
                .header("Authorization", "Bearer " + tokenA))
                .andExpect(status().isForbidden());
    }

    // ------------------------------------------------------------------
    // Muscle groups endpoint
    // ------------------------------------------------------------------

    @Test
    void muscleGroupsEndpointReturnsOrderedGroups() throws Exception {
        MvcResult result = authorizedGet("/api/muscle-groups", tokenA);
        JsonNode data = objectMapper.readTree(result.getResponse().getContentAsString()).path("data");

        // The endpoint may contain groups seeded by other test classes; this
        // class asserts its own 14 are present and ordered among themselves.
        List<String> expectedOrder = List.of("Chest", "Back", "Shoulders", "Biceps", "Triceps",
                "Forearms", "Quadriceps", "Hamstrings", "Glutes", "Calves",
                "Abs", "Traps", "Lats", "Lower Back");
        List<Integer> seenOrders = new ArrayList<>();
        for (JsonNode g : data) {
            int idx = expectedOrder.indexOf(g.path("name").asText());
            if (idx >= 0) {
                seenOrders.add(idx);
            }
        }
        assertThat(seenOrders).containsExactlyElementsOf(expectedOrder.stream()
                .map(expectedOrder::indexOf).toList());
    }
}
