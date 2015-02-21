#!/bin/sh

# First we need to get a few things from S3

# A "fixed" version of Spark (Thanks Markus!!!!)
echo "pulling down a patched version of Spark (Thanks Markus!!!!)"
aws s3 cp s3://morris-datasets/ENRON/demo/spark-1.2.1.tar.gz .
tar xf spark-1.2.1.tar.gz
sleep 2

# The dataset
echo "pulling down the dataset"
aws s3 cp s3://morris-datasets/ENRON/demo/enron.avro .
echo "pushing it into hadoop"
hadoop fs -put enron.avro .

# some utilities
echo "pulling down some utilities (Thanks Markus!!!! Again!!!)"
aws s3 cp s3://morris-datasets/ENRON/demo/mailrecord-utils-0.9.0-SNAPSHOT-shaded.jar .

set SPARK_HOME=spark-1.2.1-hadoop2.4
set PATH=$SPARK_HOME/bin:$PATH
