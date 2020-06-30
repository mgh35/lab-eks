#!/bin/zsh

set -e
cd "$(dirname "$0")"

#brew install awscli
#brew install aws-iam-authenticator
#
#aws configure



########################
# Template cluster setup

SOURCE_REPO=https://github.com/terraform-providers/terraform-provider-aws.git source_repo
SOURCE_PATH=examples/eks-getting-started

git clone $SOURCE_REPO source_repo
mkdir terraform
cp source_repo/$SOURCE_PATH/*.tf terraform/
echo "Copied from \`$SOURCE_PATH/\` at $SOURCE_REPO" > terraform/README.md
rm -rf source_repo
