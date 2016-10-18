#!/usr/bin/env bash

set -e

: ${SL_VM_NAME_PREFIX:?}
: ${SL_VM_DOMAIN:?}
: ${SL_DATACENTER:?}
: ${SL_VLAN_PUBLIC:?}
: ${SL_VLAN_PRIVATE:?}
: ${SL_USERNAME:?}
: ${SL_API_KEY:?}
: ${BOSH_DIRECTOR_USERNAME:?}
: ${BOSH_DIRECTOR_PASSWORD:?}

source /etc/profile.d/chruby.sh
chruby 2.1.7

# inputs
# paths will be resolved in a separate task so use relative paths

BOSH_RELEASE_URI="file://../$(echo bosh-release/*.tgz)"
CPI_RELEASE_URI="file://../$(echo cpi-release/*.tgz)"
STEMCELL_URI="file://../$(echo stemcell/*.tgz)"
BOSH_CLI="$(pwd)/$(echo bosh-cli/bosh-cli-*)"
chmod +x ${BOSH_CLI}

# outputs
output_dir="$(pwd)/director-state"

cat > "${output_dir}/director.yml" <<EOF
---
name: stemcell-smoke-tests-director

releases:
  - name: bosh
    url: ${BOSH_RELEASE_URI}
  - name: bosh-softlayer-cpi
    url: ${CPI_RELEASE_URI}

resource_pools:
  - name: vms
    network: default
    stemcell:
      url: ${STEMCELL_URI}
    cloud_properties:
      VmNamePrefix: $SL_VM_NAME_PREFIX
      Domain: $SL_VM_DOMAIN
      StartCpus: 4
      MaxMemory: 8192
      EphemeralDiskSize: 100
      Datacenter:
        Name: $SL_DATACENTER
      HourlyBillingFlag: true
      LocalDiskFlag: false
      PrimaryNetworkComponent:
        NetworkVlan:
          Id: $SL_VLAN_PUBLIC
      PrimaryBackendNetworkComponent:
        NetworkVlan:
          Id: $SL_VLAN_PRIVATE

disk_pools:
  - name: disks
    disk_size: 20_000

networks:
  - name: default
    type: dynamic
    dns:
    - 8.8.8.8
    - 10.0.80.11
    - 10.0.80.12

jobs:
  - name: bosh
    instances: 1

    templates:
      - {name: nats, release: bosh}
      - {name: postgres, release: bosh}
      - {name: blobstore, release: bosh}
      - {name: director, release: bosh}
      - {name: health_monitor, release: bosh}
      - {name: powerdns, release: bosh}
      - {name: softlayer_cpi, release: bosh-softlayer-cpi}

    resource_pool: vms
    persistent_disk_pool: disks

    networks:
      - name: default

    properties:
      nats:
        address: 127.0.0.1
        user: nats
        password: nats-password

      postgres: &db
        host: 127.0.0.1
        user: postgres
        password: postgres-password
        database: bosh
        adapter: postgres

      blobstore:
        address: 127.0.0.1
        port: 25250
        provider: dav
        director: {user: director, password: director-password}
        agent: {user: agent, password: agent-password}

      director:
        address: 127.0.0.1
        name: stemcell-smoke-tests-director
        db: *db
        cpi_job: softlayer_cpi
        user_management:
          provider: local
          local:
            users:
              - {name: ${BOSH_DIRECTOR_USERNAME}, password: ${BOSH_DIRECTOR_PASSWORD}}

      hm:
        http: {user: hm, password: hm-password}
        director_account: {user: ${BOSH_DIRECTOR_USERNAME}, password: ${BOSH_DIRECTOR_PASSWORD}}
        resurrector_enabled: true

      agent: {mbus: "nats://nats:nats-password@127.0.0.1:4222"}

      dns:
        address: 127.0.0.1
        db: *db

      softlayer: &softlayer
        username: $SL_USERNAME
        apiKey: $SL_API_KEY

cloud_provider:
  template: {name: softlayer_cpi, release: bosh-softlayer-cpi}

  mbus: "https://mbus:mbus-password@$SL_VM_NAME_PREFIX.$SL_VM_DOMAIN:6868"

  properties:
    softlayer: *softlayer
    agent: {mbus: "https://mbus:mbus-password@$SL_VM_NAME_PREFIX.$SL_VM_DOMAIN:6868"}
    blobstore: {provider: local, path: /var/vcap/micro_bosh/data/cache}
    ntp: [0.pool.ntp.org, 1.pool.ntp.org]
EOF

echo "deploying BOSH..."

pushd ${output_dir}

  set +e
  logfile=$(mktemp)
  BOSH_LOG_PATH=$logfile ${BOSH_CLI} create-env director.yml
  bosh_cli_exit_code="$?"
  set -e

popd

function finish {
    echo "Final state of director deployment:"
    echo "=========================================="
    cat ${output_dir}/director-state.json
    echo "=========================================="

    echo "Director IP:"
    echo "=========================================="
    cat /etc/hosts | grep "$SL_VM_NAME_PREFIX.$SL_VM_DOMAIN" | awk '{print $1}' | tee ${output_dir}/director-info
    echo "=========================================="

}
trap finish EXIT

if [ ${bosh_cli_exit_code} != 0 ]; then
  echo "bosh-cli deploy failed!" >&2
  cat $logfile >&2
  exit ${bosh_cli_exit_code}
fi
