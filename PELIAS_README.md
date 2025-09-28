# Pelias Geocoder Setup for SimpleDispatch

This document describes the Pelias geocoding service setup for the SimpleDispatch infrastructure project.

## Overview

Pelias is an open-source geocoding system that provides:

- **Forward geocoding**: Convert addresses/place names to coordinates
- **Reverse geocoding**: Convert coordinates to addresses/place names
- **Swiss data coverage**: Includes Swiss cities, regions, and administrative boundaries
- **REST API**: Simple HTTP endpoints for integration

## Services

The Pelias stack includes these Docker containers:

| Service                | Port | Description                       |
| ---------------------- | ---- | --------------------------------- |
| `pelias_api`           | 4000 | Main API endpoint                 |
| `pelias_elasticsearch` | 9200 | Search engine and data storage    |
| `pelias_libpostal`     | 4400 | Address parsing service           |
| `pelias_placeholder`   | 4100 | Administrative boundaries service |
| `pelias_pip-service`   | 4200 | Point-in-polygon service          |
| `pelias_interpolation` | 4300 | Address interpolation service     |

## Quick Start

### 1. Start Services

```bash
./manage-pelias.sh start
```

### 2. Check Status

```bash
./manage-pelias.sh status
```

### 3. Test Functionality

```bash
./manage-pelias.sh test
```

## API Usage

### Search for Places

```bash
# Search for a city
curl "http://localhost:4000/v1/search?text=Zurich"

# Search for a street
curl "http://localhost:4000/v1/search?text=Bahnhofstrasse,Zurich"

# Using the management script
./manage-pelias.sh search "Bahnhofstrasse, Zurich"
```

### Reverse Geocoding

```bash
# Convert coordinates to address
curl "http://localhost:4000/v1/reverse?point.lat=47.3769&point.lon=8.5417"

# Using the management script
./manage-pelias.sh reverse 47.3769 8.5417
```

## Integration with SimpleDispatch

### JavaScript/Node.js Example

```javascript
const axios = require("axios");

async function geocodeAddress(address) {
  const response = await axios.get(
    `http://localhost:4000/v1/search?text=${encodeURIComponent(address)}`
  );
  const features = response.data.features;

  if (features.length > 0) {
    const result = features[0];
    return {
      name: result.properties.name,
      coordinates: result.geometry.coordinates, // [lon, lat]
      confidence: result.properties.confidence,
      label: result.properties.label,
    };
  }
  return null;
}

async function reverseGeocode(lat, lon) {
  const response = await axios.get(
    `http://localhost:4000/v1/reverse?point.lat=${lat}&point.lon=${lon}`
  );
  const features = response.data.features;

  if (features.length > 0) {
    return features[0].properties.label;
  }
  return null;
}

// Example usage
geocodeAddress("Bahnhofstrasse, Zurich").then(console.log);
reverseGeocode(47.3769, 8.5417).then(console.log);
```

### Python Example

```python
import requests

def geocode_address(address):
    url = f"http://localhost:4000/v1/search?text={address}"
    response = requests.get(url)
    data = response.json()

    if data['features']:
        result = data['features'][0]
        return {
            'name': result['properties']['name'],
            'coordinates': result['geometry']['coordinates'],  # [lon, lat]
            'confidence': result['properties']['confidence'],
            'label': result['properties']['label']
        }
    return None

def reverse_geocode(lat, lon):
    url = f"http://localhost:4000/v1/reverse?point.lat={lat}&point.lon={lon}"
    response = requests.get(url)
    data = response.json()

    if data['features']:
        return data['features'][0]['properties']['label']
    return None

# Example usage
print(geocode_address("Bahnhofstrasse, Zurich"))
print(reverse_geocode(47.3769, 8.5417))
```

## Data Coverage

Currently includes:

- ✅ **Who's on First**: Administrative boundaries (countries, regions, cities, neighborhoods)
- ✅ **Swiss postal codes**: Complete coverage
- ❌ **OpenStreetMap**: Streets and POIs (requires additional import step)
- ❌ **OpenAddresses**: Detailed address data (requires additional setup)

## Management Commands

```bash
# Start all services
./manage-pelias.sh start

# Stop all services
./manage-pelias.sh stop

# Check service status
./manage-pelias.sh status

# Run functionality tests
./manage-pelias.sh test

# Search for places
./manage-pelias.sh search "Basel"

# Reverse geocode coordinates
./manage-pelias.sh reverse 47.3769 8.5417

# View API logs
./manage-pelias.sh logs
```

## Troubleshooting

### Services Won't Start

1. Check port conflicts: `lsof -i :4000 -i :9200`
2. Ensure Docker has enough resources (8GB+ RAM recommended)
3. Check logs: `./manage-pelias.sh logs`

### No Results Found

1. Verify services are running: `./manage-pelias.sh status`
2. Check if data was imported: `curl http://localhost:9200/pelias/_count`
3. Try broader search terms

### Performance Issues

1. Increase Docker memory allocation
2. Consider excluding interpolation service if not needed
3. Monitor Elasticsearch health: `curl http://localhost:9200/_cluster/health`

## Directory Structure

```
pelias-project/
├── .env                    # Environment configuration
├── docker-compose.yml      # Service definitions
├── pelias.json            # Pelias configuration
└── data/                  # Data storage
    ├── elasticsearch/     # Search index data
    ├── whosonfirst/      # Administrative boundary data
    └── placeholder/      # Compiled boundary database
```

## Configuration Files

- **`.env`**: Project settings and data directory path
- **`pelias.json`**: Pelias configuration (focus point: Zurich, data sources)
- **`docker-compose.yml`**: Docker service definitions and port mappings

## Next Steps

To improve geocoding capabilities, consider:

1. **Import OpenStreetMap data** for detailed street information
2. **Add OpenAddresses data** for precise address matching
3. **Configure interpolation** for house number estimation
4. **Add custom CSV data** for specific locations
5. **Set up monitoring** and health checks

## Resources

- [Pelias Documentation](https://github.com/pelias/documentation)
- [Pelias Docker Repository](https://github.com/pelias/docker)
- [API Documentation](https://github.com/pelias/documentation/blob/master/search.md)
