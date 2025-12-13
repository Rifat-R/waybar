#!/bin/bash

# Get the ID of the next sink
NEXT_SINK=$(pactl list short sinks | awk '{print $1}' | \
            awk -v current=$(pactl get-default-sink | sed 's/[^0-9]//g') \
            '$1 > current {print $1; exit} END {if (!found) print first}' \
            first=$(pactl list short sinks | awk 'NR==1{print $1}'))

# If we reached the end of the list, wrap around to the first one
if [ -z "$NEXT_SINK" ]; then
    NEXT_SINK=$(pactl list short sinks | awk 'NR==1{print $1}')
fi

# Set the new default sink
pactl set-default-sink "$NEXT_SINK"

# Move currently playing streams to the new sink (optional but recommended)
pactl list short sink-inputs | awk '{print $1}' | while read -r input; do
    pactl move-sink-input "$input" "$NEXT_SINK"
done
