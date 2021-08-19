#!/bin/bash

# Wait for Nomad to be ready
echo "Waiting for Nomad to be ready..."
status=$(nomad node status -self -json | jq -r .Status)
while [ "$status" != "ready" ]; do
  sleep 1
  status=$(nomad node status -self -json | jq -r .Status)
done

nomad run /vagrant/jobs/countdash.job.nomad