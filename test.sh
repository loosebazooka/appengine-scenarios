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

  mvn -f $pom clean appengine:run &
  sleep 4
  curl http://localhost:8080/test | grep -z $pattern || return 1
  mvn -f $pom appengine:stop || return 1
  echo "DEVSERVER PASS $project"
}

testDeploy ()
{
  local project=$1
  local pattern=$2
  local pom=${project}/pom.xml

  echo "START DEPLOY $project"
  mvn -f $pom clean appengine:deploy &> /dev/null || return 1
  curl http://${project}-dot-${gcpproject}.appspot.com/test  &> /dev/null | grep -z $pattern && echo $project is up || (echo "$pattern not found in $project" && return 1)
  gcloud app services delete $project --quiet &> /dev/null || return 1
  echo "DEPLOY PASS $project"
}

#testDevserver '1-standard' 'Hello.*FilePermission'
#testDevserver '2-java7' 'Hello.*Flex'

testDeploy '1-standard' 'Hello.*FilePermission' \
& testDeploy '2-java7' 'Hello.*Flex' \
& testDeploy '3-java7-extended' 'Hello.*Flex' \
& testDeploy '4-java8-compat' 'Hello.*Flex' \
& testDeploy '5-java8-compat-extended' 'Hello.*Flex' \
& testDeploy '6-java8-jetty9' 'Hello.*Flex' \
& testDeploy '7-java8-jetty9-extended' 'Hello.*Flex' \
& testDeploy '8-java8' 'Hello.*Flex' \
& wait && echo DONE SUCCESS || echo DONE FAILURE

kill 0


