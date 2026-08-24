CREATE TABLE users (
    id              UUID PRIMARY KEY,
    phone_number    VARCHAR(20) UNIQUE,
    email           VARCHAR(255) UNIQUE,
    display_name    VARCHAR(100) NOT NULL,
    google_id       VARCHAR(255) UNIQUE,
    avatar_url      VARCHAR(500),
    height_cm       DECIMAL(5,1),
    weight_kg       DECIMAL(5,1),
    date_of_birth   DATE,
    gender          VARCHAR(20),
    unit_preference VARCHAR(10) NOT NULL DEFAULT 'METRIC',
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_unit_preference CHECK (unit_preference IN ('METRIC', 'IMPERIAL')),
    CONSTRAINT chk_gender CHECK (gender IN ('MALE', 'FEMALE', 'OTHER', 'PREFER_NOT_TO_SAY') OR gender IS NULL),
    CONSTRAINT chk_auth_method CHECK (phone_number IS NOT NULL OR google_id IS NOT NULL)
);

CREATE TABLE refresh_tokens (
    id              UUID PRIMARY KEY,
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token           VARCHAR(500) NOT NULL UNIQUE,
    expires_at      TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_refresh_token_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE INDEX idx_users_phone ON users(phone_number);
CREATE INDEX idx_users_google_id ON users(google_id);
CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);
