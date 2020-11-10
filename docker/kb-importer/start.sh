#!/bin/sh

#kaybee update
cd /kb-importer/data
./kaybee update --force

#Adding certs
certs=`ls /kb-importer/data/certs | grep -v readme.txt`
for cert in $certs; do
   keytool -import -alias $cert -storepass changeit -keystore /usr/lib/jvm/java-1.8-openjdk/jre/lib/security/cacerts -file /kb-importer/data/certs/$cert -noprompt
done

#run kaybee import for kaybeeconf-initial.yaml
if [ ! -f /kb-importer/data/init ]
then
  echo `date` " Running Initial Kaybee Import"
  #wait for the backend to start
  sleep 120
  ./kaybee pull -c conf/kaybeeconf-initial.yaml
  ./kaybee merge -c conf/kaybeeconf-initial.yaml
  ./kaybee export -t steady -c conf/kaybeeconf-initial.yaml
  chmod +x steady.sh
  sh steady.sh
  touch /kb-importer/data/init
  echo `date` " Kaybee Import Done"
fi

#create a cron job kaybeeconf.yaml
crontab -l > tmpcron
if ! cat tmpcron | grep "kb-importer.sh"
then
    if [ -z "$KB_IMPORTER_CRON" ]
    then
      echo "0 0 * * * /kb-importer/kb-importer.sh" >> tmpcron
    else
      echo "$KB_IMPORTER_CRON" " /kb-importer/kb-importer.sh" >> tmpcron
    fi
fi
crontab tmpcron
rm tmpcron
crond -f
