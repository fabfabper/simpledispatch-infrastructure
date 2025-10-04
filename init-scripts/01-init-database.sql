--- Initialize simpledispatch database schema
--- This script runs automatically when the PostgreSQL container starts for the first time

--- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

--- Create schemas
CREATE SCHEMA IF NOT EXISTS dispatch;
CREATE SCHEMA IF NOT EXISTS audit;

--- Set default search path
ALTER DATABASE simpledispatch SET search_path TO dispatch, public;

--- Create basic tables for a dispatch system (example)
CREATE TABLE IF NOT EXISTS dispatch.units (
    id VARCHAR(20) PRIMARY KEY NOT NULL,
    record_id UUID NOT NULL DEFAULT uuid_generate_v4(),
    status INTEGER NOT NULL DEFAULT 0,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    type INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dispatch.events (
    id SERIAL PRIMARY KEY NOT NULL,
    record_id UUID NOT NULL DEFAULT uuid_generate_v4(),
    status INTEGER NOT NULL DEFAULT 0,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6),
    type VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- CREATE TABLE IF NOT EXISTS dispatch.users (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     username VARCHAR(255) UNIQUE NOT NULL,
--     email VARCHAR(255) UNIQUE NOT NULL,
--     password_hash VARCHAR(255) NOT NULL,
--     role VARCHAR(50) DEFAULT 'user',
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
-- );

-- CREATE TABLE IF NOT EXISTS dispatch.vehicles (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     license_plate VARCHAR(20) UNIQUE NOT NULL,
--     vehicle_type VARCHAR(50) NOT NULL,
--     capacity_kg DECIMAL(10,2),
--     status VARCHAR(20) DEFAULT 'available',
--     driver_id UUID REFERENCES dispatch.users(id),
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
-- );

-- CREATE TABLE IF NOT EXISTS dispatch.dispatches (
--     id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
--     origin_address TEXT NOT NULL,
--     destination_address TEXT NOT NULL,
--     pickup_time TIMESTAMP WITH TIME ZONE,
--     delivery_time TIMESTAMP WITH TIME ZONE,
--     status VARCHAR(20) DEFAULT 'pending',
--     vehicle_id UUID REFERENCES dispatch.vehicles(id),
--     driver_id UUID REFERENCES dispatch.users(id),
--     priority INTEGER DEFAULT 1,
--     notes TEXT,
--     created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
--     updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
-- );

--- Create indexes for better performance
-- CREATE INDEX IF NOT EXISTS idx_users_email ON dispatch.users(email);
-- CREATE INDEX IF NOT EXISTS idx_users_username ON dispatch.users(username);
-- CREATE INDEX IF NOT EXISTS idx_vehicles_status ON dispatch.vehicles(status);
-- CREATE INDEX IF NOT EXISTS idx_vehicles_license_plate ON dispatch.vehicles(license_plate);
-- CREATE INDEX IF NOT EXISTS idx_dispatches_status ON dispatch.dispatches(status);
-- CREATE INDEX IF NOT EXISTS idx_dispatches_pickup_time ON dispatch.dispatches(pickup_time);
-- CREATE INDEX IF NOT EXISTS idx_dispatches_vehicle_id ON dispatch.dispatches(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_units_id ON dispatch.units(id);
CREATE INDEX IF NOT EXISTS idx_events_id ON dispatch.events(id);

--- Create audit table for tracking changes
CREATE TABLE IF NOT EXISTS audit.dispatch_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(255) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(10) NOT NULL, -- INSERT, UPDATE, DELETE
    old_values JSONB,
    new_values JSONB,
    changed_by UUID,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

--- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION dispatch.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

--- Create triggers to automatically update updated_at
-- CREATE TRIGGER update_users_updated_at
--     BEFORE UPDATE ON dispatch.users
--     FOR EACH ROW EXECUTE FUNCTION dispatch.update_updated_at_column();

-- CREATE TRIGGER update_vehicles_updated_at
--     BEFORE UPDATE ON dispatch.vehicles
--     FOR EACH ROW EXECUTE FUNCTION dispatch.update_updated_at_column();

-- CREATE TRIGGER update_dispatches_updated_at
--     BEFORE UPDATE ON dispatch.dispatches
--     FOR EACH ROW EXECUTE FUNCTION dispatch.update_updated_at_column();

CREATE TRIGGER update_units_updated_at
    BEFORE UPDATE ON dispatch.units
    FOR EACH ROW EXECUTE FUNCTION dispatch.update_updated_at_column();

CREATE TRIGGER update_events_updated_at
    BEFORE UPDATE ON dispatch.events
    FOR EACH ROW EXECUTE FUNCTION dispatch.update_updated_at_column();

--- Grant appropriate permissions
GRANT USAGE ON SCHEMA dispatch TO simpledispatch_user;
GRANT USAGE ON SCHEMA audit TO simpledispatch_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA dispatch TO simpledispatch_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA audit TO simpledispatch_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA dispatch TO simpledispatch_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA audit TO simpledispatch_user;

--- Insert some sample data (optional)
-- INSERT INTO dispatch.users (username, email, password_hash, role) VALUES
--     ('admin', 'admin@simpledispatch.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3nh8/YV6Jm', 'admin'),
--     ('driver1', 'driver1@simpledispatch.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3nh8/YV6Jm', 'driver'),
--     ('dispatcher1', 'dispatcher1@simpledispatch.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj3nh8/YV6Jm', 'dispatcher')
-- ON CONFLICT (email) DO NOTHING;
INSERT INTO dispatch.units (id, status, latitude, longitude, type) VALUES
    ('unit1', 0, 47.3769, 8.5417, 'ambulance'),
    ('unit2', 1, 47.3744, 8.5514, 'firetruck'),
    ('unit3', 0, 47.3673, 8.5500, 'policecar');
INSERT INTO dispatch.events (status, latitude, longitude, type) VALUES
    (0, 47.3780, 8.5400, 'medical'),
    (1, 47.3750, 8.5450, 'fire'),
    (0, 47.3700, 8.5520, 'crime');

COMMIT;
