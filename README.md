# osutop-repeats
Count how many repeats you have in your osu! top play. Now you can shame your friends for having 11 padorus in their top play.

# Usage
Usage: $0 [ -u USERNAME ] [ -k API_KEY ] [ -s SEARCH_TERM ] [ -m MODE ]

-m is optional, and defaults to 0 (osu!standard)

To get a specific name, pipe the output to grep:
    ./osutop-repeats.sh -u mrlacpeanut -k api_key | grep "PADORU / PADORU"
