#!/usr/bin/env bash

set -eu

fly -t ci-test set-pipeline \
 -p bosh:stemcells:3312.x \
 -c ci/pipelines/stemcells/pipeline.yml \
