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

zonewithresources=$1

# Create a settings
cmd="python neoload test-settings --zone ${zonewithresources} --scenario sanityScenario create \"Test settings CLI to run\""
out=`eval $cmd`
assertJsonEquals '.name' '"Test settings CLI to run"'
assertJsonEquals '.description' null
assertJsonEquals '.scenarioName' '"sanityScenario"'
assertJsonEquals '.testResultNamingPattern' '"#${runID}"'
assertJsonEquals ".lgZoneIds.${zonewithresources}" 1
assertJsonEquals '.controllerZoneId' "\"${zonewithresources}\""


# Upload a project
cmd='python neoload project --path tests/neoload_projects/example_1 upload'
out=`eval $cmd`
assertJsonEquals '.projectName' '"NeoLoad-CLI-example-2_0"'
assertJsonEquals '.scenarios[0].scenarioName' '"sanityScenario"'


# Deploy resources
cmd='python neoload docker prepare'
out=`eval $cmd`
echo "[DONE]" $cmd $out

cmd='python neoload docker attach'
out=`eval $cmd`
echo "[DONE]" $cmd $out


# Run the test
cmd='python neoload run --scenario sanityScenario'
out=`eval $cmd > run.log`
echo "[DONE]" $cmd "Write output to file run.log"
echo ">>> You MUST check manually that the differences below are ONLY IDs and numbers !!"
diff run.log tests/integration/expected/run.log


# UnDeploy resources
cmd='python neoload docker detach'
out=`eval $cmd`
echo "[DONE]" $cmd $out


