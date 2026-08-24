CREATE TABLE food_items (
    id              UUID PRIMARY KEY,
    name            VARCHAR(300) NOT NULL,
    brand           VARCHAR(200),
    serving_size    DECIMAL(8,2) NOT NULL,
    serving_unit    VARCHAR(30) NOT NULL,
    calories        DECIMAL(8,2) NOT NULL,
    protein_g       DECIMAL(7,2) NOT NULL DEFAULT 0,
    carbs_g         DECIMAL(7,2) NOT NULL DEFAULT 0,
    fat_g           DECIMAL(7,2) NOT NULL DEFAULT 0,
    fiber_g         DECIMAL(7,2),
    is_vegetarian   BOOLEAN NOT NULL DEFAULT FALSE,
    food_category   VARCHAR(50),
    is_verified     BOOLEAN NOT NULL DEFAULT FALSE,
    barcode         VARCHAR(50),
    is_custom       BOOLEAN NOT NULL DEFAULT FALSE,
    created_by      UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_calories_positive CHECK (calories >= 0),
    CONSTRAINT chk_protein_positive CHECK (protein_g >= 0),
    CONSTRAINT chk_carbs_positive CHECK (carbs_g >= 0),
    CONSTRAINT chk_fat_positive CHECK (fat_g >= 0)
);

CREATE TABLE nutrition_entries (
    id              UUID PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    meal_type       VARCHAR(20) NOT NULL,
    logged_at       TIMESTAMP WITH TIME ZONE NOT NULL,
    notes           TEXT,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_meal_type CHECK (meal_type IN (
        'BREAKFAST', 'LUNCH', 'DINNER', 'SNACK', 'PRE_WORKOUT', 'POST_WORKOUT'
    ))
);

CREATE TABLE nutrition_entry_items (
    id                  UUID PRIMARY KEY,
    nutrition_entry_id  UUID NOT NULL REFERENCES nutrition_entries(id) ON DELETE CASCADE,
    food_item_id        UUID NOT NULL REFERENCES food_items(id),
    quantity            DECIMAL(8,2) NOT NULL,
    serving_unit        VARCHAR(30) NOT NULL,
    calories            DECIMAL(8,2) NOT NULL,
    protein_g           DECIMAL(7,2) NOT NULL,
    carbs_g             DECIMAL(7,2) NOT NULL,
    fat_g               DECIMAL(7,2) NOT NULL,
    created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_quantity_positive CHECK (quantity > 0)
);

CREATE INDEX idx_food_items_name ON food_items USING gin (to_tsvector('english', name));
CREATE INDEX idx_food_items_barcode ON food_items(barcode);
CREATE INDEX idx_food_items_category ON food_items(food_category);
CREATE INDEX idx_food_items_vegetarian ON food_items(is_vegetarian);
CREATE INDEX idx_nutrition_entries_user ON nutrition_entries(user_id);
CREATE INDEX idx_nutrition_entries_date ON nutrition_entries(logged_at);
CREATE INDEX idx_nutrition_entry_items_entry ON nutrition_entry_items(nutrition_entry_id);
