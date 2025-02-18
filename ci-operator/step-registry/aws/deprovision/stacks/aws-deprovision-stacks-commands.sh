#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

trap 'CHILDREN=$(jobs -p); if test -n "${CHILDREN}"; then kill ${CHILDREN} && wait; fi' TERM

export AWS_SHARED_CREDENTIALS_FILE="${CLUSTER_PROFILE_DIR}/.awscred"
REGION="${LEASED_RESOURCE}"

echo "Deleting AWS CloudFormation stacks"

stack_list="${SHARED_DIR}/to_be_removed_cf_stack_list"
if [ -e "${stack_list}" ]; then
    for stack_name in `tac ${stack_list}`; do 
        echo "Deleting stack ${stack_name} ..."
        aws --region $REGION cloudformation delete-stack --stack-name "${stack_name}" &
        wait "$!"
        echo "Deleted stack ${stack_name}"

        aws --region $REGION cloudformation wait stack-delete-complete --stack-name "${stack_name}" &
        wait "$!"
        echo "Waited for stack ${stack_name}"
    done
fi
exit 0