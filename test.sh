#!/bin/bash

# echo commands
#set -x

JAVA_HOME=/usr/local/buildtools/java/jdk8
testOutput="test_output.txt"

# clear testOutput file
echo "" > $testOutput

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

  if [ $buildTool = "maven" ]; then
    devAppServerStart="mvn -f ${project}/pom.xml clean appengine:start"
    devAppServerStop="mvn -f ${project}/pom.xml appengine:stop"
  else # buildtool = "gradle"
    devAppServerStart="( cd ${project} && ./gradlew clean appengineStart )"
    devAppServerStop="( cd ${project} && ./gradlew appengineStop )"
  fi

  eval "${devAppServerStart} >> ${testOutput} 2>&1"

  if curl --silent http://localhost:8080/test | grep -z $pattern &> /dev/null
  then
    echo "DEVSERVER $project is up" 
  else
    echo "*** FAIL ***: DEVSERVER $project didn't come up"
    return 1
  fi

  eval $devAppServerStop &> /dev/null 
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

  if [ $buildTool = "maven" ]; then
    deploy="mvn -f ${project}/pom.xml clean appengine:deploy"
  else # buildtool = "gradle"
    deploy="( cd ${project} && ./gradlew clean appengineDeploy )"
  fi

  echo "START DEPLOY $project"
  if eval "$deploy >> ${testOutput} 2>&1" \
    && curl --silent $url \
    && curlOut=$(curl --silent $url) \
    && echo $curlOut | grep -z $pattern &> /dev/null
  then
    echo $project is up
  else
    echo "** DEPLOY FAIL $project: $pattern not found in $project"
    echo $curlOut
    echo "goose"
    curlOut2=$(curl --silent $url)
    echo $curlOut2
    echo $url
#    curl --silent $url
    return 1
  fi

  echo "DELETING $project service"
  gcloud app services delete $project --quiet &> /dev/null
  echo "DEPLOY PASS $project"
  return 0
}

#testDevserver '1-standard' 'Hello.*FilePermission'
testDevserver '4-java8-compat' 'Hello.*Flex'

#testDeploy '1-standard' 'Hello.*FilePermission' \
#& testDeploy '2-java7' 'Hello.*Flex' \
#& testDeploy '3-java7-extended' 'Hello.*Flex' \
#& testDeploy '4-java8-compat' 'Hello.*Flex' \
#& testDeploy '5-java8-compat-extended' 'Hello.*Flex' \
#& testDeploy '6-java8-jetty9' 'Hello.*Flex' \
#& testDeploy '7-java8-jetty9-extended' 'Hello.*Flex' \
#& testDeploy '8-java8' 'Hello.*Flex' \
#testDeploy '9-java8-compat-flex' 'Hello.*Flex' \
#& testDeploy '10-java8-flex' 'Hello.*Flex' \
#& wait && echo DONE SUCCESS || echo DONE FAILURE

kill 0


