#!/bin/bash

# echo commands
#set -x

JAVA_HOME=/usr/local/buildtools/java/jdk8


# get cloud project from inputs
if [ "$#" -ne 2 ]; then
  echo "usage $0 <cloud-project> <gradle/maven>"
  exit 1
fi
gcpproject=$1
buildTool=$2

if [ $buildTool != "gradle" ] && [ $buildTool != "maven" ]; then
  echo "bad build tool: $buildTool, specify gradle or maven"
  exit 1
fi


testDevserver ()
{
  local project=$1
  local pattern=$2
  local url=http://localhost:8080/test
  local outputFile=devserver.${project}.out

  if [ $buildTool = "maven" ]; then
    devAppServerStart="mvn -f ${project}/pom.xml clean appengine:start -U"
    devAppServerStop="mvn -f ${project}/pom.xml appengine:stop -U"
  else # buildtool = "gradle"
    devAppServerStart="( cd ${project} && ./gradlew clean appengineStart --refresh-dependencies)"
    devAppServerStop="( cd ${project} && ./gradlew appengineStop --refresh-dependencies)"
  fi

  if eval ${devAppServerStart} &> $outputFile \
    && curl --silent $url | grep -z "$pattern" &> /dev/null
  then
    echo "DEVSERVER $project is up"
  else
    echo "*** FAIL ***: DEVSERVER $project didn't come up"
    return 1
  fi

  eval $devAppServerStop &>> $outputFile
  # need to sleep a little for server to shutdown
  sleep 4
  echo "DEVSERVER PASS $project"

  return 0
}

testDeploy ()
{
  local project=$1
  local pattern=$2
  local pom=${project}/pom.xml
  local url=http://${project}-dot-${gcpproject}.appspot.com/test
  local outputFile=deploy.${project}.out

  if [ $buildTool = "maven" ]; then
    deploy="mvn -f ${project}/pom.xml clean appengine:deploy -Dapp.deploy.version=${project} -U"
  else # buildtool = "gradle"
    deploy="( cd ${project} && ./gradlew clean appengineDeploy --refresh-dependencies)"
  fi

  echo "START DEPLOY $project"
  if eval $deploy &> $outputFile \
    && curl --silent $url &> /dev/null && sleep 5 && curl --silent $url | grep -z "$pattern" &> /dev/null
  then
    echo $project is up
    echo "DELETING $project version"
    gcloud app versions delete $project --quiet &>> $outputFile
    echo "DEPLOY PASS $project"
    return 0
  else
    echo "*** FAIL ***: DEPLOY FAILED $project: "$pattern" not found in $project"
    echo $url
    curl --silent $url &>> $outputFile
    echo "DELETING $project version"
    gcloud app version delete $project --quiet &>> /dev/null
    return 1
  fi

}



testDevserver '1-standard' 'Hello.*FilePermission'
testDevserver '2-java7' 'Hello.*Flex'
testDevserver '3-java7-extended' 'Hello.*Flex'
testDevserver '4-java8-compat' 'Hello.*Flex'
testDevserver '5-java8-compat-extended' 'Hello.*Flex'
testDevserver '9-java8-compat-flex' 'Hello.*Flex'

testDeploy '1-standard' 'Hello.*FilePermission' \
& testDeploy '2-java7' 'Hello.*Flex' \
& testDeploy '3-java7-extended' 'Hello.*Custom Flex' \
& testDeploy '4-java8-compat' 'Hello.*Flex' \
& testDeploy '5-java8-compat-extended' 'Hello.*Custom Flex' \
& testDeploy '6-java8-jetty9' 'Hello.*Flex' \
& testDeploy '7-java8-jetty9-extended' 'Hello.*Custom Flex' \
& testDeploy '8-java8' 'Hello.*Flex' \
& testDeploy '9-java8-compat-flex' 'Hello.*Flex' \
& testDeploy '10-java8-flex' 'Hello.*Flex' \
& wait && echo DONE

kill 0

