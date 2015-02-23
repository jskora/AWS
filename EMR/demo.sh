#!/bin/sh
set -e

# Simple script to start an EMR cluster running Spark


AWS_CLI=`which aws`
#KEYNAME=`whoami`SparkKey
current_time=$(date "+%Y.%m.%d-%H.%M.%S")
KEYNAME=Sparkey.$current_time

if [ $? -ne 0 ]; then
  echo "AWS CLI is not installed. Do a pip install awscli and try again; exiting"
  exit 1
else
  echo "Using AWS CLI found at $AWS_CLI"
aws configure
fi

SSH=`which ssh`
if [ $? -ne 0 ]; then
  echo "SSH is not installed. Something might be wrong with your PATH or box"
  exit 1
else
  echo "SSH is installed"
fi


aws ec2 create-key-pair --key-name $KEYNAME --query 'KeyMaterial' --output text > ./${KEYNAME}.pem && chmod 600 ./${KEYNAME}.pem && export keypair=./${KEYNAME}.pem
if [ $? -eq 0 ]; then
     echo "Creating SSH key to access the cluster"
else
    echo "Unable to create SSH key"
fi

EMR_CLUSTER_JSON=$(aws emr create-cluster --name SparkCluster --ami-version 3.2 --instance-type m3.xlarge --instance-count 3   --ec2-attributes KeyName=$KEYNAME --applications Name=Hive   --bootstrap-actions Path=s3://support.elasticmapreduce/spark/install-spark)

export EMR_CLUSTER_ID=$(echo ${EMR_CLUSTER_JSON} | grep ClusterId | sed 's/.*\"\(.*\)\".*/\1/')

echo "${EMR_CLUSTER_ID} starting, this could take a minute (or five) so hang tight!" 1>&2

while aws emr describe-cluster --cluster-id ${EMR_CLUSTER_ID} | grep -q "STARTING"; do
  sleep 3
done

echo "Bootstrapping ${EMR_CLUSTER_ID}"

while aws emr describe-cluster --cluster-id ${EMR_CLUSTER_ID} | grep -q "BOOTSTRAPPING"; do
  sleep 3
done

echo "Logging into your cluster"
echo
echo "If you get disconnected you can access it again with aws emr ssh --cluster-id ${EMR_CLUSTER_ID} --key-pair-file $keypair"

sleep 2


while aws emr describe-cluster --cluster-id ${EMR_CLUSTER_ID} | grep -q "RUNNING"; do
  aws emr ssh --cluster-id ${EMR_CLUSTER_ID} --key-pair-file $keypair --command 'wget https://s3.amazonaws.com/morris-datasets/ENRON/demo/setup.sh && sh setup.sh'
break
done
