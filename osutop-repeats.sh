#!/bin/bash
# TODO: Add exit_abnormal
usage(){ 
	echo ""
	echo "Usage: $0 [ -u USERNAME ] [ -k API_KEY ] [ -s SEARCH_TERM ] [ -m MODE ]"
	echo "-s is optional. If -s isn't passed, show all songs in top 100, sorted by how many times it occurs"
	echo "-m is optional, and defaults to 0 (osu!standard)"
	echo ""
	echo "ALWAYS put SEARCH_TERM in double quotes ("")" 
	echo ""
	echo "To get a specific name, pipe the output to grep"
	echo "$ -u mrlacpeanut -k api_key | grep "PADORU / PADORU""
}
exit_abnormal(){
	usage
	exit 1
}
list_all=0
while getopts :u:k:s:m:h option
do
    case "${option}" in
    u) 
        USERNAME=${OPTARG};;
	k)
        KEY=${OPTARG};;
	s)
        SEARCH=${OPTARG};;
	m)
        MODE=${OPTARG};;
    h)
		exit_abnormal;;
	:) 
        if [ ${OPTARG} = m ]; then 
            MODE=0   # Defaults to osu!standard if gamemode isn't specified
        elif [ ${OPTARG} = k ]; then 
	        echo "Error: -${OPTARG} requires an argument(API v1 key). If you don't have one, get it at https://osu.ppy.sh/p/api"
            exit_abnormal
        elif [ ${OPTARG} = s ]; then
		    list_all=1  # No search term, just search and sort everything
        elif [ ${OPTARG} = u ]; then
		    echo "Error: -${OPTARG} requires an argument(osu! username)."
    		exit_abnormal
	    fi;; 
	*)  exit_abnormal;;
	esac
done

if [ "${MODE}" = "" ]; then MODE=0; fi
if [ "${KEY}" = "" ]; then
	echo "Error: Requires an API v1 key. If you don't have one, get it at https://osu.ppy.sh/p/api"
	exit_abnormal
fi
if [ "${SEARCH}" = "" ]; then list_all=1; fi
if [ "${USERNAME}" = "" ]; then 
	echo "Error: Requires an osu! username."
	exit_abnormal 
fi

# Check if the API key given is valid 
#REAL_API_KEY=$(curl -s "https://osu.ppy.sh/api/get_beatmaps?b=75&k=${KEY}" | jq -r .error)
if [ "${REAL_API_KEY}" = "Please provide a valid API key." ]; then
	echo "Please provide a valid osu!API v1 key. If you don't have one, get it at https://osu.ppy.sh/p/api"
	exit_abnormal
fi

# The fun part.
TOP_100_ID_STRING=$(curl -s "https://osu.ppy.sh/api/get_user_best?k=${KEY}&u=${USERNAME}&type=string&m=${MODE}&limit=100" | jq -r '.[].beatmap_id' | tr "\n" " ")
IFS=' ' read -r -a TOP_100_ID_ARRAY <<< "$TOP_100_ID_STRING"

for i in {0..99}
do
	TOP_100_SONG_ARRAY[$i]=$(curl -s "https://osu.ppy.sh/api/get_beatmaps?k=${KEY}&b=${TOP_100_ID_ARRAY[$i]}" | jq -r '. | to_entries[] | .value.title')
done 
IFS=$'\n' sorted=($(sort <<<"${TOP_100_SONG_ARRAY[*]}"))
unset IFS

#output
printf "%s\n" "${sorted[@]}" | uniq -c | sort -nr; 

 


