-- Aven Fit — local development database setup
-- Usage: psql -U postgres -f backend/scripts/setup-dev-db.sql
-- Dev-only credentials; production uses environment-managed secrets.

CREATE USER avenfit WITH PASSWORD 'avenfit_dev_password';
CREATE DATABASE avenfit_dev OWNER avenfit;
GRANT ALL PRIVILEGES ON DATABASE avenfit_dev TO avenfit;
