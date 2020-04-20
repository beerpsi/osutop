#!/usr/bin/env bash
usage(){ 
    echo ""
    echo "Usage: $0 [ -u USERNAME ] [ -k API_KEY ] [ -c COUNT ] [ -m MODE ] [ -s SORTING_MODE ] [ -w WEIGHTEDNESS] "
    echo "SORTING_MODE can be title or accuracy."
    echo "-m is optional, and defaults to 0 (osu!standard)"
    echo "-c COUNT searches in the top COUNT plays. -c is optional, and defaults to searching in top 100. This might be especially useful if ppy is getting mad at the amount of requests your API key is using."
    echo "-w WEIGHTEDNESS is optional. Default behaviour is WEIGHTEDNESS=1, or convert raw pp to weighted pp before sum."
    echo ""
    echo "To get a specific name, pipe the output to grep"
    echo "$ -u mrlacpeanut -k api_key | grep "PADORU / PADORU""
}

exit_abnormal(){
    usage
    exit 1
}

mod_parser(){
	MOD_DECIMAL=$1

	# Convert to binary
	MOD_BINARY=$(echo "obase=2;${MOD_DECIMAL}" | bc)

	#Pad leading zeroes, if the length of string isn't 29
	while [ ${#MOD_BINARY} -ne 29 ];
	do
    	MOD_BINARY="0"${MOD_BINARY}
	done	

	#Byte scheme for MOD_BINARY
	#0 0000 0000 0000 0[0]0[0] 0[0]00 0000 0000
	#From the first to the 29th bit, the RANKED mods are:
	MOD_ARRAY[0]="MI" #[0] bit is Mirror mod (MR or MI)
	MOD_ARRAY[14]="PF" #[14] bit is PF
	MOD_ARRAY[16]="SO" #[16] bit is SO
	MOD_ARRAY[18]="FL" #[18] bit is FL
	MOD_ARRAY[19]="NC" #[19] bit is NC
	MOD_ARRAY[20]="HT" #[20] bit is HT
	MOD_ARRAY[22]="DT" #[22] bit is DT
	MOD_ARRAY[23]="SD" #[23] bit is SD
	MOD_ARRAY[24]="HR" #[24] bit is HR
	MOD_ARRAY[25]="HD" #[25] bit is HD
	MOD_ARRAY[27]="EZ" #[27] bit is EZ
	MOD_ARRAY[28]="NF" #[28] bit is NF

	MOD_RETURN=""
	for (( i = 0; i < 29 ; i++ )) 
	do
    	if [ "${MOD_BINARY:$i:1}" = "1" ]; then
    		if [ "$i" = "14" ]; then
    			remove_SD=1
    		elif [ "$i" = "19" ]; then
    			remove_DT=1
    		elif [[ "$i" = "22" && "${remove_DT}" = "1" ]]; then
    			continue
    		elif [[ "$i" = "23" && "${remove_SD}" = "1" ]]; then
    			continue
    		fi 
        	MOD_RETURN="${MOD_RETURN}${MOD_ARRAY[$i]}" 
    	fi
	done
	if [ "${MOD_BINARY}" = "00000000000000000000000000000" ]; then
    	MOD_RETURN="NM"
    fi
	echo "${MOD_RETURN}"
}

sort_by_accuracy(){
	# Syntax: sort_by_accuracy [username] [api_key] [count] [mode]
	# Retrive the get_user_best file and put them in a temp folder so we dont have to make 300 requests to peppy's API
	USERNAME=$1
	KEY=$2
	COUNT=$3
	MODE=$4
	curl -s "https://osu.ppy.sh/api/get_user_best?k=${KEY}&u=${USERNAME}&type=string&m=${MODE}&limit=${COUNT}" > temp.json
	COUNT_300_STRING=$(jq -r '.[].count300' temp.json | tr "\n" " ")
	COUNT_100_STRING=$(jq -r '.[].count100' temp.json | tr "\n" " ")
	COUNT_50_STRING=$(jq -r '.[].count50' temp.json | tr "\n" " ")
	COUNT_MISS_STRING=$(jq -r '.[].countmiss' temp.json | tr "\n" " ")

	IFS=' ' read -r -a COUNT_300_ARRAY <<< "${COUNT_300_STRING}"
	IFS=' ' read -r -a COUNT_100_ARRAY <<< "${COUNT_100_STRING}"
	IFS=' ' read -r -a COUNT_50_ARRAY <<< "${COUNT_50_STRING}"
	IFS=' ' read -r -a COUNT_MISS_ARRAY <<< "${COUNT_MISS_STRING}"

	for (( i = 0; i < ${COUNT} ; i++ )) 
	do
		ACCURACY_TEMP=$(echo "(${COUNT_300_ARRAY[$i]}*300+${COUNT_100_ARRAY[$i]}*100+${COUNT_50_ARRAY[$i]}*50)/(300*(${COUNT_300_ARRAY[$i]}+${COUNT_100_ARRAY[$i]}+${COUNT_50_ARRAY[$i]}+${COUNT_MISS_ARRAY[$i]}))*100" | bc -l)
		ACCURACY_ARRAY[$i]=$(echo "$ACCURACY_TEMP $((i+1))")
	done 
	IFS=$'\n' sorted=($(sort <<<"${ACCURACY_ARRAY[*]}"))
	unset IFS

	#output
	printf "%s\n" "${sorted[@]}" | sort -nr; 
}

sort_by_title(){
	# Syntax: sort_by_title [username] [api_key] [count] [mode] [weighted]
	USERNAME=$1
	KEY=$2
	COUNT=$3
	MODE=$4
	WEIGHTED=$5
	curl -s "https://osu.ppy.sh/api/get_user_best?k=${KEY}&u=${USERNAME}&type=string&m=${MODE}&limit=${COUNT}" > temp.json
	TOP_N_ID_STRING=$(jq -r '.[].beatmap_id' temp.json | tr "\n" " ")
	IFS=' ' read -r -a TOP_N_ID_ARRAY <<< "$TOP_N_ID_STRING"

	for (( i = 0; i < ${COUNT} ; i++ )) 
	do
		TOP_N_SONG_ARRAY[$i]=$(curl -s "https://osu.ppy.sh/api/get_beatmaps?k=${KEY}&b=${TOP_N_ID_ARRAY[$i]}" | jq -r '. | to_entries[] | .value.title')
	done
	
	#Get pp values to add them next to the mod values
	PP_VALUES=$(jq -r '.[].pp' temp.json | tr "\n" " ")
	IFS=' ' read -r -a PP_VALUES_ARR <<< "${PP_VALUES}"
	#Convert raw pp to weighted pp, if needed
	if [ "${WEIGHTED}" = "1" ]; then
		for (( i = 0; i < ${COUNT} ; i++ )) 
		do
			PP_VALUES_ARR[$i]=$(echo "${PP_VALUES_ARR[$i]}*0.95^$i" | bc)
		done
	fi	
	#Convert the spaces in ${TOP_N_SONG_ARRAY} to underscores because spaces is a delimiter
	for (( i = 0; i < ${COUNT} ; i++ )) 
	do
		TOP_N_SONG_ARRAY[$i]=$(echo "${TOP_N_SONG_ARRAY[$i]}" | tr " " "_")
	done 	


	#Add weighted pp next to the song titles
	for (( i = 0; i < ${COUNT} ; i++ )) 
	do
		OVERALL_ARR[$i]="${TOP_N_SONG_ARRAY[$i]} ${PP_VALUES_ARR[$i]}"
	done 	
 
	IFS=$'\n' sorted=($(sort <<<"${OVERALL_ARR[*]}"))
	unset IFS
	printf "%s\n" "${sorted[@]}" > temp.txt 

	#Sum, sort, remove underscore
	awk '{ seen[$1] += $2 } END { for (i in seen) print i, seen[i] }' temp.txt | sort -nr -k2 | tr "_" " " | sed 's/$/pp/'
}
sort_by_mod(){
	# Syntax: sort_by_mod [username] [api_key] [count] [mode] [weighted]
	USERNAME=$1
	KEY=$2
	COUNT=$3
	MODE=$4	
	WEIGHTED=$5
	curl -s "https://osu.ppy.sh/api/get_user_best?k=${KEY}&u=${USERNAME}&type=string&m=${MODE}&limit=${COUNT}" > temp.json
	TOP_N_DECIMAL_MODS=$(jq -r '.[].enabled_mods' temp.json | tr "\n" " ")
	IFS=' ' read -r -a TOP_N_DECIMAL_MODS_ARR <<< "${TOP_N_DECIMAL_MODS}"

	# Convert the enabled_mods number into the letters(DTHR,...)
	for (( i = 0; i < ${COUNT} ; i++ )) 
	do
		TOP_N_MOD_ARR[$i]=$(mod_parser ${TOP_N_DECIMAL_MODS_ARR[$i]})
	done 

	#Get pp values to add them next to the mod values
	PP_VALUES=$(jq -r '.[].pp' temp.json | tr "\n" " ")
	IFS=' ' read -r -a PP_VALUES_ARR <<< "${PP_VALUES}"
	#Convert raw pp to weighted pp,  if needed
	if [ "${WEIGHTED}" = "1" ]; then
		for (( i = 0; i < ${COUNT} ; i++ )) 
		do
			PP_VALUES_ARR[$i]=$(echo "${PP_VALUES_ARR[$i]}*0.95^$i" | bc)
		done
	fi 	
	#Add weighted pp next to the mods
	for (( i = 0; i < ${COUNT} ; i++ )) 
	do
		OVERALL_ARR[$i]="${TOP_N_MOD_ARR[$i]} ${PP_VALUES_ARR[$i]}"
	done 	


	# Sort
	IFS=$'\n' sorted=($(sort <<<"${OVERALL_ARR[*]}"))
	unset IFS
	printf "%s\n" "${sorted[@]}" > temp.txt 
	
	#Sum, sort again by pp, and pp at the end
	awk '{ seen[$1] += $2 } END { for (i in seen) print i, seen[i] }' temp.txt | sort -nr -k2 | sed 's/$/pp/'

	
}
api_key_check(){
	# Check if the API key given is valid 
	# Syntax: api_key_check [api_key]
	KEY=$1
	REAL_API_KEY=$(curl -s "https://osu.ppy.sh/api/get_beatmaps?b=75&k=${KEY}" | jq -r .error)
	if [ "${REAL_API_KEY}" = "Please provide a valid API key." ]; then
		echo "Please provide a valid osu!API v1 key. If you don't have one, get it at https://osu.ppy.sh/p/api"
		exit_abnormal
	fi
}


while getopts :u:k:c:m:s:w:h option
do
    case "${option}" in
    u) 
        USERNAME=${OPTARG};;
    k)
        KEY=${OPTARG};;
    c)
        COUNT=${OPTARG};;
    m)
        MODE=${OPTARG};;
    s) 
		SORTING=${OPTARG};;
	w)
		WEIGHTED=${OPTARG};;
    h)
		exit_abnormal;;
    :) 
        if [ ${OPTARG} = m ]; then 
            MODE=0   # Defaults to osu!standard if gamemode isn't specified
        elif [ ${OPTARG} = k ]; then 
	    	echo "Error: -${OPTARG} requires an argument(API v1 key). If you don't have one, get it at https://osu.ppy.sh/p/api"
            exit_abnormal
        elif [ ${OPTARG} = c ]; then
            echo "Error: -${OPTARG} requires an argument(count)."
	    	exit_abnormal
        elif [ ${OPTARG} = u ]; then
	    	echo "Error: -${OPTARG} requires an argument(osu! username)."
    	    exit_abnormal
    	elif [ ${OPTARG} = s ]; then
    		echo "Error: -${OPTARG} requires an argument(sorting mode). It can be either title, accuracy or mod."
    		exit_abnormal
		elif [ ${OPTARG} = w ]; then
    		echo "Error: -${OPTARG} requires an argument(weightedness). It can be either 0(unweighted) or 1(weighted)."
    	fi;; 
    *)  exit_abnormal;;
    esac
done

if [ "${MODE}" = "" ]; then MODE=0; fi
if [ "${KEY}" = "" ]; then
	echo "Error: Requires an API v1 key. If you don't have one, get it at https://osu.ppy.sh/p/api"
	exit_abnormal
fi
if [ "${COUNT}" = "" ]; then COUNT=100; fi
if [ "${USERNAME}" = "" ]; then 
	echo "Error: Requires an osu! username."
	exit_abnormal 
fi
if [ "${SORTING}" = "" ]; then
	echo "Error: Requires a sorting mode (accuracy, title, mod)"
	exit_abnormal
fi
if [ "${WEIGHTED}" = "" ]; then
	WEIGHTED=1
fi

# Check for valid API key
api_key_check ${KEY}

# If it reaches here then API key is already valid.
if [ "${SORTING}" = "accuracy" ]; then
	sort_by_accuracy ${USERNAME} ${KEY} ${COUNT} ${MODE}
	exit 0
elif [ "${SORTING}" = "title" ]; then
	sort_by_title ${USERNAME} ${KEY} ${COUNT} ${MODE} ${WEIGHTED}
	exit 0
elif [ "${SORTING}" = "mod" ]; then
	sort_by_mod ${USERNAME} ${KEY} ${COUNT} ${MODE} ${WEIGHTED}
	exit 0
fi
