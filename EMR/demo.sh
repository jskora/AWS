#!/bin/sh

# Simple script to start an EMR cluster running Spark


AWS_CLI=`which aws`

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


aws ec2 create-key-pair --key-name Sparkey --query 'KeyMaterial' --output text > ~/Sparkey.pem && chmod 600 ~/Sparkey.pem && export keypair=~/Sparkey.pem
if [ $? -eq 0 ]; then
     echo "Creating SSH key to access the cluster"
else
    echo "Unable to create SSH key"
fi

EMR_CLUSTER_JSON=$(aws emr create-cluster --name SparkCluster --ami-version 3.2 --instance-type m3.xlarge --instance-count 3   --ec2-attributes KeyName=Sparkey --applications Name=Hive   --bootstrap-actions Path=s3://support.elasticmapreduce/spark/install-spark)

export EMR_CLUSTER_ID=$(echo ${EMR_CLUSTER_JSON} | grep ClusterId | sed 's/.*\"\(.*\)\".*/\1/')

echo "${EMR_CLUSTER_ID} starting, this could take a minute (or five) so hang tight!" 1>&2

while aws emr describe-cluster --cluster-id ${EMR_CLUSTER_ID} | grep -q "STARTING"; do
  sleep 3
done

echo "Bootstrapping ${EMR_CLUSTER_ID}"

while aws emr describe-cluster --cluster-id ${EMR_CLUSTER_ID} | grep -q "BOOTSTRAPPING"; do
  sleep 3
done

echo "Starting Spark"
echo
echo
echo
echo "If you exit, you can access the cluster by doing an aws emr ssh --cluster-id ${EMR_CLUSTER_ID} --key-pair-file $keypair"

echo
echo 
echo
sleep 3


while aws emr describe-cluster --cluster-id ${EMR_CLUSTER_ID} | grep -q "RUNNING"; do
  aws emr ssh --cluster-id ${EMR_CLUSTER_ID} --key-pair-file $keypair --command 'MASTER=yarn-client /home/hadoop/spark/bin/spark-shell'
break
done
