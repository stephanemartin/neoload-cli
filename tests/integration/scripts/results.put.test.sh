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

assertEquals () {
  if [ "$1" != "$2" ]; then
    echo "[FAILURE] $cmd"
	echo "   Expected: $2"
	echo "   but was: $1"
  else
    echo "[SUCCESS] $cmd"
  fi
}


# Ls
cmd='python neoload test-results ls "SLA test"'
out=`eval $cmd`
assertJsonEquals '.id' '"d30fdcc2-319e-4be5-818e-f1978907a3ce"'
assertJsonEquals '.name' '"SLA test"'
assertJsonEquals '.description' '"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean consequat, tellus nec aliquam faucibus, leo nisi congue nisi, eu euismod eros ex non risus. Donec a nisl eu erat tincidunt aliquam. Duis hendrerit est quis feugiat tincidunt. Fusce cursus dictum tortor, ut hendrerit neque vehicula ut. Cras nisl urna, tincidunt sit amet velit vitae, mattis porta tellus. Quisque maximus ipsum orci, a hendrerit orci malesuada et. Ut rhoncus velit massa, ut condimentum mi dignissim eget. Cras convallis enim ipsum, vel ultrices purus vestibulum at. Nunc laoreet sed metus sit amet iaculis. Sed id sodales tortor, ac vehicula urna. Suspendisse potenti. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Curabitur porttitor, nulla ut scelerisque semper, risus lorem tempor felis, a aliquet sapien ex ac enim. Fusce et massa vitae tellus accumsan vestibulum quis nec ex."'
assertJsonEquals '.qualityStatus' '"PASSED"'


# Use
cmd='python neoload test-results use "SLA test"'
out=`eval $cmd`
echo $out
echo "[DONE] $cmd"


# Put all fields
cmd='python neoload test-results --rename "SLA test renamed" --description "some desc" --quality-status FAILED put'
out=`eval $cmd`
assertJsonEquals '.id' '"d30fdcc2-319e-4be5-818e-f1978907a3ce"'
assertJsonEquals '.name' '"SLA test renamed"'
assertJsonEquals '.description' '"some desc"'
assertJsonEquals '.qualityStatus' '"FAILED"'


# Put only required fields
cmd='python neoload test-results --rename "SLA test renamed2" --quality-status PASSED put'
out=`eval $cmd`
assertJsonEquals '.id' '"d30fdcc2-319e-4be5-818e-f1978907a3ce"'
assertJsonEquals '.name' '"SLA test renamed2"'
assertJsonEquals '.description' '""'
assertJsonEquals '.qualityStatus' '"PASSED"'


# Summary
cmd='python neoload test-results summary'
out=`eval $cmd > summary.txt`
assertEquals "$(`diff summary.txt tests/integration/expected/summary.txt`)" ""


# Junit-SLA
cmd='python neoload test-results junitsla'
out=`eval $cmd`
assertEquals "$(`diff junit-sla.xml tests/integration/expected/junit-sla.xml`)" ""


# Junit-SLA with file name
cmd='python neoload test-results --junit-file junit.xml junitsla'
out=`eval $cmd`
assertEquals "$(`diff junit.xml tests/integration/expected/junit-sla.xml`)" ""


