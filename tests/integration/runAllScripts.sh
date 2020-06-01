#!/bin/bash

python neoload login --url https://preprod-neoload-api.saas.neotys.com/ 12345678912345678901ae6d8af6abcdefabcdefabcdef
tests/integration/scripts/results.delete.test.sh
tests/integration/scripts/results.put.test.sh
tests/integration/scripts/run.docker.test.sh defaultzone
tests/integration/scripts/settings.create.delete.test.sh
tests/integration/scripts/settings.patch.test.sh
tests/integration/scripts/settings.put.test.sh
tests/integration/scripts/wait.docker.test.sh defaultzone
tests/integration/scripts/zones.ls.test.sh
