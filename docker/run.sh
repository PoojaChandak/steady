#!/bin/sh

echo -e "\n[+] Building new archives"

( set -x; mvn -U -e -Dhttp.proxyHost=${HTTP_PROXY_HOST} -Dhttp.proxyPort=${HTTP_PROXY_PORT} -Dhttps.proxyHost=${HTTPS_PROXY_HOST} -Dhttps.proxyPort=${HTTPS_PROXY_PORT} ${mvn_flags} clean install)

if [ $? -ne 0 ]; then
	echo -e "\n[!] Couldn't build new archives"
	exit 1
fi

echo -e '\n[+] Cleaning old archives'

rm /exporter/**/*.?ar 2> /dev/null

VULAS_JAVA_COMPONENTS="frontend-apps frontend-bugs patch-lib-analyzer rest-backend rest-lib-utils"

echo -e '\n[+] Copying new archives'

for i in $VULAS_JAVA_COMPONENTS ; do
    cp $i/target/*.?ar /exporter/$i/
done

echo -e '\n[+] Done'

sleep 1