#!/bin/bash

# Gate commits to several projects on a VM running those projects
# configured by devstack.

# Copyright (C) 2011-2013 OpenStack Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
#
# See the License for the specific language governing permissions and
# limitations under the License.

# Most of the work of this script is done in functions so that we may
# easily redirect their stdout / stderr to log files.

source $WORKSPACE/devstack-gate/functions.sh

start_timer

PROJECTS="openstack-dev/devstack $PROJECTS"
PROJECTS="openstack-dev/grenade $PROJECTS"
PROJECTS="openstack-dev/pbr $PROJECTS"
PROJECTS="openstack-infra/jeepyb $PROJECTS"
PROJECTS="openstack-infra/pypi-mirror $PROJECTS"
PROJECTS="openstack-infra/tripleo-ci $PROJECTS"
PROJECTS="openstack/ceilometer $PROJECTS"
PROJECTS="openstack/cinder $PROJECTS"
PROJECTS="openstack/cliff $PROJECTS"
PROJECTS="openstack/diskimage-builder $PROJECTS"
PROJECTS="openstack/django_openstack_auth $PROJECTS"
PROJECTS="openstack/glance $PROJECTS"
PROJECTS="openstack/heat $PROJECTS"
PROJECTS="openstack/horizon $PROJECTS"
PROJECTS="openstack/ironic $PROJECTS"
PROJECTS="openstack/keystone $PROJECTS"
PROJECTS="openstack/marconi $PROJECTS"
PROJECTS="openstack/neutron $PROJECTS"
PROJECTS="openstack/nova $PROJECTS"
PROJECTS="openstack/os-apply-config $PROJECTS"
PROJECTS="openstack/os-collect-config $PROJECTS"
PROJECTS="openstack/os-refresh-config $PROJECTS"
PROJECTS="openstack/oslo.config $PROJECTS"
PROJECTS="openstack/oslo.messaging $PROJECTS"
PROJECTS="openstack/oslo.rootwrap $PROJECTS"
PROJECTS="openstack/oslo.vmware $PROJECTS"
PROJECTS="openstack/pycadf $PROJECTS"
PROJECTS="openstack/python-ceilometerclient $PROJECTS"
PROJECTS="openstack/python-cinderclient $PROJECTS"
PROJECTS="openstack/python-glanceclient $PROJECTS"
PROJECTS="openstack/python-heatclient $PROJECTS"
PROJECTS="openstack/python-ironicclient $PROJECTS"
PROJECTS="openstack/python-keystoneclient $PROJECTS"
PROJECTS="openstack/python-marconiclient $PROJECTS"
PROJECTS="openstack/python-neutronclient $PROJECTS"
PROJECTS="openstack/python-novaclient $PROJECTS"
PROJECTS="openstack/python-openstackclient $PROJECTS"
PROJECTS="openstack/python-saharaclient $PROJECTS"
PROJECTS="openstack/python-swiftclient $PROJECTS"
PROJECTS="openstack/python-troveclient $PROJECTS"
PROJECTS="openstack/requirements $PROJECTS"
PROJECTS="openstack/sahara $PROJECTS"
PROJECTS="openstack/sahara-dashboard $PROJECTS"
PROJECTS="openstack/stevedore $PROJECTS"
PROJECTS="openstack/swift $PROJECTS"
PROJECTS="openstack/taskflow $PROJECTS"
PROJECTS="openstack/tempest $PROJECTS"
PROJECTS="openstack/tripleo-heat-templates $PROJECTS"
PROJECTS="openstack/tripleo-image-elements $PROJECTS"
PROJECTS="openstack/tripleo-incubator $PROJECTS"
PROJECTS="openstack/trove $PROJECTS"


export BASE=/opt/stack

# The URL from which to fetch ZUUL references
export ZUUL_URL=${ZUUL_URL:-http://zuul.openstack.org/p}

# Set this variable to skip updating the devstack-gate project itself.
# Useful in development so you can edit scripts in place and run them
# directly.  Do not set in production.
# Normally not set, and we do include devstack-gate with the rest of
# the projects.
if [ -z "$SKIP_DEVSTACK_GATE_PROJECT" ]; then
    PROJECTS="openstack-infra/devstack-gate $PROJECTS"

    # Also, if we're testing devstack-gate, re-exec this script once so
    # that we can test the new version of it.
    if [[ $ZUUL_CHANGES =~ "openstack-infra/devstack-gate" ]] && [[ $RE_EXEC != "true" ]]; then
        echo "This build includes a change to devstack-gate; updating working copy."
        # Since we're early in the script, we need to update the d-g
        # copy in the workspace, not $DEST, which is what will be
        # updated later.
        setup_project openstack-infra/devstack-gate master
        cd $WORKSPACE

        re_exec_devstack_gate
    fi
fi

# Make a directory to store logs
rm -rf $WORKSPACE/logs
mkdir -p $WORKSPACE/logs

# Set to 1 to run the Tempest test suite
export DEVSTACK_GATE_TEMPEST=${DEVSTACK_GATE_TEMPEST:-0}

# Set to 1 to run the devstack exercises
export DEVSTACK_GATE_EXERCISES=${DEVSTACK_GATE_EXERCISES:-0}

# Set to 1 to run postgresql instead of mysql
export DEVSTACK_GATE_POSTGRES=${DEVSTACK_GATE_POSTGRES:-0}

# Set to 1 to use zeromq instead of rabbitmq (or qpid)
export DEVSTACK_GATE_ZEROMQ=${DEVSTACK_GATE_ZEROMQ:-0}

# Set to qpid to use qpid, or zeromq to use zeromq.
# Default set to rabbitmq
export DEVSTACK_GATE_MQ_DRIVER=${DEVSTACK_GATE_MQ_DRIVER:-"rabbitmq"}

# Set to 1 to run tempest stress tests
export DEVSTACK_GATE_TEMPEST_STRESS=${DEVSTACK_GATE_TEMPEST_STRESS:-0}

# Set to 1 to run tempest heat slow tests
export DEVSTACK_GATE_TEMPEST_HEAT_SLOW=${DEVSTACK_GATE_TEMPEST_HEAT_SLOW:-0}

# Set to 1 to run tempest large ops test
export DEVSTACK_GATE_TEMPEST_LARGE_OPS=${DEVSTACK_GATE_TEMPEST_LARGE_OPS:-0}

# Set to 1 to run tempest smoke tests serially
export DEVSTACK_GATE_SMOKE_SERIAL=${DEVSTACK_GATE_SMOKE_SERIAL:-0}

# Set to 1 to explicitly disable tempest tenant isolation. Otherwise tenant isolation setting
# for tempest will be the one chosen by devstack.
export DEVSTACK_GATE_TEMPEST_DISABLE_TENANT_ISOLATION=${DEVSTACK_GATE_TEMPEST_DISABLE_TENANT_ISOLATION:-0}

# Set to 1 to enable Cinder secure delete.
# False by default to avoid dd problems on Precise.
# https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1023755
export DEVSTACK_CINDER_SECURE_DELETE=${DEVSTACK_CINDER_SECURE_DELETE:-0}

# Set to 1 to run neutron instead of nova network
# Only applicable to master branch
export DEVSTACK_GATE_NEUTRON=${DEVSTACK_GATE_NEUTRON:-0}

# Set to 1 to run nova in cells mode instead of the default mode
export DEVSTACK_GATE_CELLS=${DEVSTACK_GATE_CELLS:-0}

# Set to 1 to run nova in with nova metadata server as a separate binary
export DEVSTACK_GATE_NOVA_API_METADATA_SPLIT=${DEVSTACK_GATE_NOVA_API_METADATA_SPLIT:-0}

# Set to 1 to run ironic baremetal provisioning service.
export DEVSTACK_GATE_IRONIC=${DEVSTACK_GATE_IRONIC:-0}

# Set to 1 to run sahara
export DEVSTACK_GATE_SAHARA=${DEVSTACK_GATE_SAHARA:-0}

# Set to 1 to run trove
export DEVSTACK_GATE_TROVE=${DEVSTACK_GATE_TROVE:-0}

# Set to 1 to run marconi
export DEVSTACK_GATE_MARCONI=${DEVSTACK_GATE_MARCONI:-0}

# Set to 0 to disable config_drive and use the metadata server instead
export DEVSTACK_GATE_CONFIGDRIVE=${DEVSTACK_GATE_CONFIGDRIVE:-1}

# Set to 1 to enable running a keystone v3 based gate
export DEVSTACK_GATE_KEYSTONE_V3=${DEVSTACK_GATE_KEYSTONE_V3:-0}

# Set the number of threads to run tempest with
DEFAULT_CONCURRENCY=$(nproc)
if [ ${DEFAULT_CONCURRENCY} -gt 3 ] ; then
    DEFAULT_CONCURRENCY=$[${DEFAULT_CONCURRENCY} / 2]
fi
export TEMPEST_CONCURRENCY=${TEMPEST_CONCURRENCY:-${DEFAULT_CONCURRENCY}}

# The following variables are set for different directions of Grenade updating
# for a stable branch we want to both try to upgrade forward n => n+1 as
# well as upgrade from last n-1 => n.
#
# i.e. stable/icehouse:
#   DGG=1 means stable/havana => stable/icehouse
#   DGGF=1 means stable/icehouse => master (or stable/juno if that's out)
export DEVSTACK_GATE_GRENADE=${DEVSTACK_GATE_GRENADE:-0}
export DEVSTACK_GATE_GRENADE_FORWARD=${DEVSTACK_GATE_GRENADE_FORWARD:-0}
# DGGPN=1 means upgrade everything but n-cpu.
export DEVSTACK_GATE_GRENADE_PARTIAL_NCPU=${DEVSTACK_GATE_GRENADE_PARTIAL_NCPU:-0}

if [ "$DEVSTACK_GATE_GRENADE" -eq "1" ]; then
    export DEVSTACK_GATE_TEMPEST=1
    if [ "$ZUUL_BRANCH" == "stable/icehouse" ]; then
        export GRENADE_OLD_BRANCH="stable/havana"
        export GRENADE_NEW_BRANCH="stable/icehouse"
    else # master
        export GRENADE_OLD_BRANCH="stable/havana"
        export GRENADE_NEW_BRANCH="master"
    fi
    if [ "$DEVSTACK_GATE_GRENADE_PARTIAL_NCPU" -eq "1" ]; then
        export DO_NOT_UPGRADE_SERVICES=[n-cpu]
    else
        export DO_NOT_UPGRADE_SERVICES=
    fi
    # the roll forward case
elif [ "$DEVSTACK_GATE_GRENADE_FORWARD" -eq "1" ]; then
    export DEVSTACK_GATE_TEMPEST=1
    if [ "$ZUUL_BRANCH" == "stable/havana" ]; then
        export GRENADE_OLD_BRANCH="stable/havana"
        export GRENADE_NEW_BRANCH="master"
    fi
fi

# Set the virtualization driver to: libvirt, openvz
export DEVSTACK_GATE_VIRT_DRIVER=${DEVSTACK_GATE_VIRT_DRIVER:-libvirt}

# See switch below for this -- it gets set to 1 when tempest
# is the project being gated.
export DEVSTACK_GATE_TEMPEST_FULL=${DEVSTACK_GATE_TEMPEST_FULL:-0}

# Set to enable running full tempest with testr:
export DEVSTACK_GATE_TEMPEST_TESTR_FULL=${DEVSTACK_GATE_TEMPEST_TESTR_FULL:-0}

# Set to 1 to run all tempest tests
export DEVSTACK_GATE_TEMPEST_ALL=${DEVSTACK_GATE_TEMPEST_ALL:-0}

# Set to a regex to run tempest with a custom regex filter
export DEVSTACK_GATE_TEMPEST_REGEX=${DEVSTACK_GATE_TEMPEST_REGEX:-""}

# Set to 1 if running the openstack/requirements integration test
export DEVSTACK_GATE_REQS_INTEGRATION=${DEVSTACK_GATE_REQS_INTEGRATION:-0}

# Set this variable to override the mirror selection script. Set to a
# nonexistant location to disable mirror selection
export DEVSTACK_GATE_SELECT_MIRROR=${DEVSTACK_GATE_SELECT_MIRROR:-/usr/local/jenkins/slave_scripts/select-mirror.sh}

# Set to 0 to disable clean logs enforcement (3rd party CI might want to do this
# until they get their driver cleaned up)
export DEVSTACK_GATE_CLEAN_LOGS=${DEVSTACK_GATE_CLEAN_LOGS:-1}

# Set this to the time in minutes that the gate test should be allowed
# to run before being aborted (default 60).
export DEVSTACK_GATE_TIMEOUT=${DEVSTACK_GATE_TIMEOUT:-60}

# Set this to override the branch selected for testing (in
# single-branch checkouts; not used for grenade)
export OVERRIDE_ZUUL_BRANCH=${OVERRIDE_ZUUL_BRANCH:-$ZUUL_BRANCH}

if ! function_exists "gate_hook"; then
  # the command we use to run the gate
  function gate_hook {
	sed -i '/function setup_localrc/i \
rm -rf \/opt\/stack\/new\/devstack \
git clone https:\/\/github.com\/alekseychuprin\/devstack.git \/opt\/stack\/new\/devstack' /opt/stack/new/devstack-gate/devstack-vm-gate.sh
    remaining_time
    timeout -s 9 ${REMAINING_TIME}m $BASE/new/devstack-gate/devstack-vm-gate.sh
  }
fi

echo "Triggered by: https://review.openstack.org/$ZUUL_CHANGE patchset $ZUUL_PATCHSET"
echo "Pipeline: $ZUUL_PIPELINE"
echo "Available disk space on this host:"
indent df -h

echo "Setting up the host"
echo "... this takes a few seconds (logs at logs/devstack-gate-setup-host.txt.gz)"
tsfilter setup_host &> $WORKSPACE/logs/devstack-gate-setup-host.txt

if [ "$DEVSTACK_GATE_GRENADE" -eq "1" -o "$DEVSTACK_GATE_GRENADE_FORWARD" -eq "1" ]; then
    echo "Setting up the new (migrate to) workspace"
    echo "... this takes 3 - 5 minutes (logs at logs/devstack-gate-setup-workspace-new.txt.gz)"
    tsfilter setup_workspace $GRENADE_NEW_BRANCH $BASE/new &> \
        $WORKSPACE/logs/devstack-gate-setup-workspace-new.txt
    echo "Setting up the old (migrate from) workspace ..."
    echo "... this takes 3 - 5 minutes (logs at logs/devstack-gate-setup-workspace-old.txt.gz)"
    tsfilter setup_workspace $GRENADE_OLD_BRANCH $BASE/old &> \
        $WORKSPACE/logs/devstack-gate-setup-workspace-old.txt
else
    echo "Setting up the workspace"
    echo "... this takes 3 - 5 minutes (logs at logs/devstack-gate-setup-workspace-new.txt.gz)"
    tsfilter setup_workspace $OVERRIDE_ZUUL_BRANCH $BASE/new &> \
        $WORKSPACE/logs/devstack-gate-setup-workspace-new.txt
fi

# relocate and symlink logs into $BASE to save space on the root filesystem
if [ -d "$WORKSPACE/logs" -a \! -e "$BASE/logs" ]; then
    sudo mv $WORKSPACE/logs $BASE/
    ln -s $BASE/logs $WORKSPACE/
fi

# Run pre test hook if we have one
if function_exists "pre_test_hook"; then
  echo "Running pre_test_hook"
  xtrace=$(set +o | grep xtrace)
  set -o xtrace
  tsfilter pre_test_hook | tee $WORKSPACE/devstack-gate-pre-test-hook.txt
  sudo mv $WORKSPACE/devstack-gate-pre-test-hook.txt $BASE/logs/
  $xtrace
fi

# Run the gate function
echo "Running gate_hook"
gate_hook
GATE_RETVAL=$?
RETVAL=$GATE_RETVAL

if [ $GATE_RETVAL -ne 0 ]; then
    echo "ERROR: the main setup script run by this job failed - exit code: $GATE_RETVAL"
    echo "    please look at the relevant log files to determine the root cause"
fi

# Run post test hook if we have one
if [ $GATE_RETVAL -eq 0 ] && function_exists "post_test_hook"; then
  echo "Running post_test_hook"
  xtrace=$(set +o | grep xtrace)
  set -o xtrace -o pipefail
  tsfilter post_test_hook | tee $WORKSPACE/devstack-gate-post-test-hook.txt
  RETVAL=$?
  sudo mv $WORKSPACE/devstack-gate-post-test-hook.txt $BASE/logs/
  set +o pipefail
  $xtrace
fi

if [ $GATE_RETVAL -eq 137 ] && [ -f $WORKSPACE/gate.pid ] ; then
    GATEPID=`cat $WORKSPACE/gate.pid`
    echo "Killing process group ${GATEPID}"
    sudo kill -s 9 -${GATEPID}
fi

echo "Cleaning up host"
echo "... this takes 3 - 4 minutes (logs at logs/devstack-gate-cleanup-host.txt.gz)"
tsfilter cleanup_host &> $WORKSPACE/devstack-gate-cleanup-host.txt
sudo mv $WORKSPACE/devstack-gate-cleanup-host.txt $BASE/logs/

exit $RETVAL
