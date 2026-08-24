# Backend Scripts

## Dev Database Setup (PostgreSQL)

### 1. Install PostgreSQL 16+

- Windows: https://www.postgresql.org/download/windows/ (or `winget install PostgreSQL.PostgreSQL.16`)
- Remember the `postgres` superuser password you set during install.

### 2. Run the setup script

From the repository root:

```bash
psql -U postgres -f backend/scripts/setup-dev-db.sql
```

This creates:

- User `avenfit` / password `avenfit_dev_password` (dev only)
- Database `avenfit_dev`, owned by `avenfit`

### 3. Verify connection

```bash
psql -U avenfit -d avenfit_dev -c "SELECT 1;"
```

The Spring Boot dev profile (`application-dev.yml`) expects PostgreSQL at
`localhost:5432` with these exact credentials.
