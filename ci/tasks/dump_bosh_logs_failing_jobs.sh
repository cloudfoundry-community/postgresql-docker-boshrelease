#!/bin/bash

set -e

function fetch_job_logs{
  job_name=$1
  job_id_or_uuid=${2:-'0'}
  job=${job_name}-${job_id_or_uuid}
  rm -rf /tmp/${job}
  mkdir -p /tmp/${job}
  bosh logs ${job_name} ${job_id_or_uuid} --dir /tmp/${job}
  tar xfz /tmp/${job}/*.tgz -O
}

task_id=$(boshcurl /deployments/${deployment}/vms\?format\=full | jq -r .id)
boshcurl /tasks/${task_id}/output\?type\=result | jq -r ". | select (.job_state != \"running\") | (.job_name, .id)"
