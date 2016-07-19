#!/bin/bash

# echo commands
#set -x

JAVA_HOME=/usr/local/buildtools/java/jdk8
gcpproject='eltsufin-sandbox'

testDevserver ()
{
  local project=$1
  local pattern=$2
  local pom=${project}/pom.xml

  mvn -f $pom clean appengine:run &> /dev/null &
  sleep 4
  if curl --silent http://localhost:8080/test | grep -z $pattern &> /dev/null
  then
    echo "DEVSERVER $project is up" 
  else
    echo "*** FAIL ***: DEVSERVER $project didn't come up"
    return 1
  fi

  mvn -f $pom appengine:stop &> /dev/null 
  echo "DEVSERVER PASS $project"

  return 0
}

testDeploy ()
{
  local project=$1
  local pattern=$2
  local pom=${project}/pom.xml

  echo "START DEPLOY $project"
  if mvn -f $pom clean appengine:deploy &> /dev/null \
    && curl --silent http://${project}-dot-${gcpproject}.appspot.com/test \
    | grep -z $pattern &> /dev/null
  then
    echo $project is up
  else
    echo "*** FAIL ***: $pattern not found in $project"
    curl --silent http://${project}-dot-${gcpproject}.appspot.com/test
    return 1
  fi

  echo "DELETING $project service"
  gcloud app services delete $project --quiet &> /dev/null
  echo "DEPLOY PASS $project"
  return 0
}

testDevserver '1-standard' 'Hello.*FilePermission'
testDevserver '4-java8-compat' 'Hello.*Flex'

testDeploy '1-standard' 'Hello.*FilePermission' \
& testDeploy '2-java7' 'Hello.*Flex' \
& testDeploy '3-java7-extended' 'Hello.*Flex' \
& testDeploy '4-java8-compat' 'Hello.*Flex' \
& testDeploy '5-java8-compat-extended' 'Hello.*Flex' \
& testDeploy '6-java8-jetty9' 'Hello.*Flex' \
& testDeploy '7-java8-jetty9-extended' 'Hello.*Flex' \
& testDeploy '8-java8' 'Hello.*Flex' \
& testDeploy '9-java8-compat-flex' 'Hello.*Flex' \
& testDeploy '10-java8-flex' 'Hello.*Flex' \
& wait && echo DONE SUCCESS || echo DONE FAILURE

kill 0


