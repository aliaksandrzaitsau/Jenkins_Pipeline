#!/bin/bash

cp -r $PROJECT_VOLUME/* $PROJECT_SRC

config_name="$PROJECT_SRC/src/main/resources/application.properties"

# initialization of fields property

prop_name="spring.data.mongodb.uri"
prop_value="mongodb:\/\/mongo_$HOSTNAME\/jobfinder"
sed -i "/$prop_name=/ s/=.*/=$prop_value/" $config_name
echo "Added to property with name is $prop_name the value of $prop_value in config file is $config_name"

prop_name="logging.level.com.elilink.*"
prop_value="DEBUG"
sed -i "/$prop_name=/ s/=.*/=$prop_value/" $config_name
echo "Added to property with name is $prop_name the value of $prop_value in config file is $config_name"

prop_name="logging.level.com.elilink.jobfinder.filter.LoggingWebFilter"
prop_value="TRACE"
sed -i "/$prop_name=/ s/=.*/=$prop_value/" $config_name
echo "Added to property with name is $prop_name the value of $prop_value in config file is $config_name"
##############################################################################################################################################################################################
config_name="$PROJECT_SRC/src/main/resources/oauth.properties"

prop_name="com.elilink.jobfinder.oauth2.clientOrigins"
prop_value="http:\/\/127.0.0.1:4201,http:\/\/kennedy:11001" # in this property we are specifying address of frontend. For this environment kennedy:10000 - backend, kennedy:10001 - frontend.
sed -i "/$prop_name=/ s/=.*/=$prop_value/" $config_name
echo "Added to property with name is $prop_name the value of $prop_value in config file is $config_name"
##############################################################################################################################################################################################
config_name="$PROJECT_SRC/src/test/resources/application.properties"

prop_name="spring.data.mongodb.uri"
prop_value="mongodb:\/\/mongo_$HOSTNAME\/jobfinder"
sed -i "/$prop_name=/ s/=.*/=$prop_value/" $config_name
echo "Added to property with name is $prop_name the value of $prop_value in config file is $config_name"
##############################################################################################################################################################################################
config_name="$PROJECT_SRC/src/main/resources/frontend.properties"

prop_name="com.elilink.jobfinder.frontendUrl"
prop_value="http:\/\/kennedy:11001"
sed -i "/$prop_name=/ s/=.*/=$prop_value/" $config_name
echo "Added to property with name is $prop_name the value of $prop_value in config file is $config_name"
##############################################################################################################################################################################################
# coping the images to /upload/freelancer/principal/74529a16-70d6-4817-9fcc-80f010e542db.jpeg
cd $PROJECT_SRC
mkdir -p upload && cd upload
mkdir -p freelancer && cd freelancer
mkdir -p principal && cd principal
wget https://www.royal-canin.ru/upload/iblock/a63/ekst.jpg # any image (for example like this)
mv * "74529a16-70d6-4817-9fcc-80f010e542db.jpeg" # rename to the desired name

cd $PROJECT_SRC
mkdir -p upload && cd upload
mkdir -p cv && cd cv
mkdir -p principal && cd principal
wget https://qph.fs.quoracdn.net/main-qimg-a8393b3d164136edd79815050a5c2a42
mv * "9389a6df-19ef-429a-ba8d-05d1021be9cf.png"

cd $PROJECT_SRC
mkdir -p upload && cd upload
mkdir -p company && cd company
mkdir -p principal && cd principal
mv /opt/pictures/edem.jpeg ./
mv /opt/pictures/moonlight.jpeg ./
############################################################################

echo "Starting build project.. (cmd mvn clean install)"
cd $PROJECT_SRC
mkdir $PROJECT_LOG/$HOSTNAME/ # create directory for maven and app logs

# !!! Skipping tests (-Dmaven.test.skip=true) because the current java version in this image - java 11,
# but project still working with java 10 that no longer supported and some tests doesn't pass with java 11
# $PROJECT_LOG/$HOSTNAME/maven.log 2>&1 - translating this log into log file
mvn clean install -Dmaven.test.skip=true > $PROJECT_LOG/$HOSTNAME/maven.log 2>&1

code_of_exit_maven_install=$? # code of completed cmd "mvn clean install"
echo "Code of exit maven install: $code_of_exit_maven_install"
echo "export CODE_OF_EXIT_MAVEN_INSTALL=$code_of_exit_maven_install" >> /root/.bashrc
echo $code_of_exit_maven_install > $PROJECT_LOG/$HOSTNAME/maven_code

####################################################################################################################################################################

echo "Run project..."
# run project with special parameter for remote debug on a port 9002!!! and translating application log into log file
setsid java \
-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:11002 \
-jar target/jobfinder-0.0.1-SNAPSHOT.jar \
> $PROJECT_LOG/$HOSTNAME/app.log 2>&1 < /dev/null &

sleep 60 # Waiting for the application to start
pid_app=$(pgrep java)

# going to check the logs
any_INFO=$(grep INFO $PROJECT_LOG/$HOSTNAME/app.log)
any_ERROR=$(grep ERROR $PROJECT_LOG/$HOSTNAME/app.log)
any_FATAL=$(grep FATAL $PROJECT_LOG/$HOSTNAME/app.log)

# endpoints
actual_example_message=$(curl localhost:8080/exampleMessage) # {"id":112,"text":"Hello, JobFinder"}
expected_example_message='{"id":112,"text":"Hello, JobFinder"}'


# pid_app != 0 that mean the application was successfully started
# contains any INFO logs
# and no ERROR, FATAL
if [[ pid_app -gt 0 \
    && "$any_INFO" \
    && ! "$any_ERROR" \
    && ! "$any_FATAL" \
    && "$actual_example_message" == "$expected_example_message" ]]
then
    code_of_exit_app_run=0
else
    code_of_exit_app_run=1
fi

echo "Code of exit application ran: $code_of_exit_app_run"
echo "export CODE_OF_EXIT_APP_RUN=$code_of_exit_app_run" >> /root/.bashrc
echo $code_of_exit_app_run > $PROJECT_LOG/$HOSTNAME/app_code
source /root/.bashrc

# infinity cycle
while true; do sleep 1000; done


