#!/bin/bash

# Pelias Geocoder Management Script for SimpleDispatch
# This script provides easy commands to manage the Pelias geocoding service

PELIAS_DIR="/Users/fabianperler/simpledispatch/simpledispatch-infrastructure/pelias-project"
PELIAS_API_URL="http://localhost:4000/v1"

cd "$PELIAS_DIR"

case "$1" in
    "start")
        echo "Starting Pelias geocoding services..."
        export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
        pelias compose up -d
        echo "Waiting for services to start..."
        sleep 10
        pelias compose ps
        ;;
    "stop")
        echo "Stopping Pelias geocoding services..."
        export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
        pelias compose down
        ;;
    "status")
        echo "Pelias service status:"
        export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
        pelias compose ps
        ;;
    "test")
        echo "Testing Pelias API..."
        echo "=== Search for Zurich ==="
        curl -s "$PELIAS_API_URL/search?text=Zurich" | jq '.features[0].properties | {name, confidence, coordinates: [.locality, .country]}'
        echo -e "\n=== Reverse geocode Zurich coordinates ==="
        curl -s "$PELIAS_API_URL/reverse?point.lat=47.3769&point.lon=8.5417" | jq '.features[0].properties | {name, layer, locality, country}'
        ;;
    "search")
        if [ -z "$2" ]; then
            echo "Usage: $0 search \"address or place name\""
            exit 1
        fi
        echo "Searching for: $2"
        curl -s "$PELIAS_API_URL/search?text=$(echo "$2" | sed 's/ /%20/g')" | jq -r '.features[] | "\(.properties.name): \(.geometry.coordinates | reverse | join(","))"'
        ;;
    "reverse")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 reverse LAT LON"
            exit 1
        fi
        echo "Reverse geocoding: $2, $3"
        curl -s "$PELIAS_API_URL/reverse?point.lat=$2&point.lon=$3" | jq -r '.features[0].properties.label // "No results found"'
        ;;
    "logs")
        echo "Showing Pelias API logs..."
        export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
        pelias compose logs api
        ;;
    *)
        echo "Pelias Geocoder Management Script"
        echo "Usage: $0 {start|stop|status|test|search|reverse|logs}"
        echo ""
        echo "Commands:"
        echo "  start                    - Start all Pelias services"
        echo "  stop                     - Stop all Pelias services" 
        echo "  status                   - Show service status"
        echo "  test                     - Run basic functionality tests"
        echo "  search \"place name\"      - Search for a place"
        echo "  reverse LAT LON          - Reverse geocode coordinates"
        echo "  logs                     - Show API logs"
        echo ""
        echo "API Endpoints:"
        echo "  Search: $PELIAS_API_URL/search?text=QUERY"
        echo "  Reverse: $PELIAS_API_URL/reverse?point.lat=LAT&point.lon=LON"
        exit 1
        ;;
esac