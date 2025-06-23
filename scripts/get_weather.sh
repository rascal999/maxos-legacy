#!/usr/bin/env bash

LAT="51.4878376"
LON="-2.6103834"

TEMP=$(curl -s "https://api.open-meteo.com/v1/forecast?latitude=$LAT&longitude=$LON&current=temperature_2m&temperature_unit=celsius" | grep -o '"temperature_2m":\s*[0-9.]*' | cut -d':' -f2 | tr -d '[:space:]')
echo "{\"text\":\"${TEMP}°C\"}"