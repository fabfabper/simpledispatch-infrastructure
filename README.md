# simpledispatch-infrastructure

Infrastructure components for the SimpleDispatch application including database, message broker, and other supporting services.

## Components

- **PostgreSQL**: Primary database for storing dispatch, vehicle, and user data
- **Redis**: Caching and session management (optional)
- **RabbitMQ**: Message broker for async communication (optional)

## Quick Start

1. **Clone and setup**:

   ```bash
   cd simpledispatch-infrastructure
   cp .env.example .env
   # Edit .env file with your preferred configuration
   ```

2. **Start all services**:

   ```bash
   docker-compose up -d
   ```

3. **Start only PostgreSQL**:

   ```bash
   docker-compose up -d postgres
   ```

4. **View logs**:

   ```bash
   docker-compose logs -f postgres
   ```

5. **Stop services**:
   ```bash
   docker-compose down
   ```

## Database Connection

- **Host**: localhost
- **Port**: 5432
- **Database**: simpledispatch
- **Username**: simpledispatch_user
- **Password**: simpledispatch_password

Connection string: `postgresql://simpledispatch_user:simpledispatch_password@localhost:5432/simpledispatch`

## Service URLs

- PostgreSQL: `localhost:5432`
- Redis: `localhost:6379`
- RabbitMQ Management UI: `http://localhost:15672` (admin/admin)
- RabbitMQ AMQP: `localhost:5672`

## Database Schema

The PostgreSQL database is automatically initialized with:

- `dispatch` schema for main application data
- `audit` schema for change tracking
- Sample tables: users, vehicles, dispatches
- Proper indexes and constraints
- Triggers for automatic timestamp updates

## Development

### Connecting to PostgreSQL

```bash
# Using psql
docker exec -it simpledispatch-postgres psql -U simpledispatch_user -d simpledispatch

# Using docker-compose exec
docker-compose exec postgres psql -U simpledispatch_user -d simpledispatch
```

### Backup and Restore

```bash
# Backup
docker exec simpledispatch-postgres pg_dump -U simpledispatch_user simpledispatch > backup.sql

# Restore
docker exec -i simpledispatch-postgres psql -U simpledispatch_user simpledispatch < backup.sql
```

### Customization

- Add custom initialization scripts to `init-scripts/` directory
- Modify `Dockerfile.postgres` for custom PostgreSQL configuration
- Update `docker-compose.yml` for additional services or configuration changes

## File Structure

```
├── Dockerfile.postgres      # Custom PostgreSQL Docker image
├── docker-compose.yml      # Multi-service orchestration
├── .env.example            # Environment variables template
├── init-scripts/           # Database initialization scripts
│   └── 01-init-database.sql
└── README.md              # This file
```
