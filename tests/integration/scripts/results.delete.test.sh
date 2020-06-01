#!/bin/bash

# Use
cmd='python neoload test-results use "d30fdcc2-319e-4be5-818e-f1978907a3ce"'
out=`eval $cmd`
echo $out
echo "[DONE] $cmd"


# Delete
cmd='python neoload test-results delete'
out=`eval $cmd`
echo $out
echo "[DONE] $cmd"

