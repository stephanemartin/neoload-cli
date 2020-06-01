#!/bin/bash

assertJsonEquals () {
  if [ "$(echo $out | jq $1)" != "$2" ]; then
    echo "[FAILURE] $cmd"
	echo "   Expected: $2"
	echo "   but jq '$1' was: $(echo $out | jq $1)"
  else
    echo "[SUCCESS] $cmd"
  fi
}

# Create
cmd='python neoload test-settings create "Test settings CLI patch"'
out=`eval $cmd`
assertJsonEquals '.name' '"Test settings CLI patch"'
assertJsonEquals '.scenarioName' null
assertJsonEquals '.description' null
assertJsonEquals '.lgZoneIds.defaultzone' 1
assertJsonEquals '.controllerZoneId' '"defaultzone"'
assertJsonEquals '.testResultNamingPattern' '"#${runID}"'


# Patch name scenario description pattern
cmd='python neoload test-settings --rename "Test settings CLI patch2" --scenario newScenario --description "my desc" --naming-pattern "pattern" patch'
out=`eval $cmd`
assertJsonEquals '.name' '"Test settings CLI patch2"'
assertJsonEquals '.scenarioName' '"newScenario"'
assertJsonEquals '.description' '"my desc"'
assertJsonEquals '.lgZoneIds.defaultzone' 1
assertJsonEquals '.controllerZoneId' '"defaultzone"'
assertJsonEquals '.testResultNamingPattern' '"pattern"'


# Patch lgs
cmd='python neoload test-settings --lgs 3 patch'
out=`eval $cmd`
assertJsonEquals '.name' '"Test settings CLI patch2"'
assertJsonEquals '.scenarioName' '"newScenario"'
assertJsonEquals '.description' '"my desc"'
assertJsonEquals '.lgZoneIds.defaultzone' 3
assertJsonEquals '.controllerZoneId' '"defaultzone"'
assertJsonEquals '.testResultNamingPattern' '"pattern"'


# Patch lgs
cmd='python neoload test-settings --lgs zone:3,zone2:4 patch'
out=`eval $cmd`
assertJsonEquals '.name' '"Test settings CLI patch2"'
assertJsonEquals '.scenarioName' '"newScenario"'
assertJsonEquals '.description' '"my desc"'
assertJsonEquals '.lgZoneIds.zone' 3
assertJsonEquals '.lgZoneIds.zone2' 4
assertJsonEquals '.controllerZoneId' '"defaultzone"'
assertJsonEquals '.testResultNamingPattern' '"pattern"'


# Patch zone
cmd='python neoload test-settings --zone myZone patch'
out=`eval $cmd`
assertJsonEquals '.name' '"Test settings CLI patch2"'
assertJsonEquals '.scenarioName' '"newScenario"'
assertJsonEquals '.description' '"my desc"'
assertJsonEquals '.lgZoneIds.zone' null
assertJsonEquals '.lgZoneIds.myZone' 1
assertJsonEquals '.controllerZoneId' '"myZone"'
assertJsonEquals '.testResultNamingPattern' '"pattern"'


# Delete
cmd='python neoload test-settings delete "Test settings CLI patch2"'
out=`eval $cmd`
assertJsonEquals '.name' '"Test settings CLI patch2"'
