#!/bin/bash

set +x

JAVA_OPTS=${JAVA_OPTS:--Djava.security.egd=file:/dev/urandom}
SECRETS_DIR=${SECRETS_DIR:-/run/secrets}

wait() {
	arr=("$@")
	start_ts=$(date +%s)
	if [  $# -eq 3 ]; then
		echo "waiting ${arr[2]} seconds for tcp service: ${arr[0]} ${arr[1]}"
	else
		echo " '-w' should have exactly 3 values: host, port and timeout, but we saw: $# "
		exit -1
	fi

	if ! [[ ${arr[1]} -ge 1 ]]; then
		echo "'port' should be a number, but it is: ${arr[1]}"
		exit -1
	fi

	if ! [[ ${arr[2]} -ge 1 ]]; then
		echo "'timeout' should be a number, but it is: ${arr[2]}"
		exit -1
	fi

    while :
    do
		nc -z -w 1  ${arr[0]} ${arr[1]}
		result=$?
		end_ts=$(date +%s)
		if [ ${result} -eq 0 ]; then
			echo "${arr[0]}|${arr[1]} available after $((end_ts - start_ts)) seconds"
			return;
		fi
		if [  $((end_ts - start_ts)) -ge ${arr[2]} ]; then
			echo "${arr[0]}|${arr[1]} timed out after $((end_ts - start_ts)) seconds"
			exit 1
		fi
	done
}


usage() {
	echo "Usage: ${0} [ -o java_opt ... ] [  -j JAR ]"
	exit 1
}

while getopts "w:o:j:" opt; do
	case $opt in
		o)
			JAVA_OPTS="$OPTARG $JAVA_OPTS"
			;;
		w)
			ARRAY=()
			X=$((OPTIND-1))
			eval "A=\$$(($X))";
			while ! [[ ${A} =~ ^- ]]; do
				ARRAY+=($A)
				X=$((X+1))
				eval "A=\$$(($X))";
			done
			wait ${ARRAY[@]}
			OPTIND=X
			;;
		j)
			JAR=$OPTARG
			;;
	esac
done

if [ -z "${JAR}" ]; then
	export JAR="*.jar"
fi

java --version
echo "starting: java $JAVA_OPTS -jar $JAR"
java $JAVA_OPTS -jar $JAR
