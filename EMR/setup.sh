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
rm enron.avro

# some utilities
echo "pulling down some utilities (Thanks Markus!!!! Again!!!)"
aws s3 cp s3://morris-datasets/ENRON/demo/log4j.properties .
aws s3 cp s3://morris-datasets/ENRON/demo/mailrecord-utils-0.9.0-SNAPSHOT-shaded.jar .

export SPARK_HOME=spark-1.2.1-hadoop2.4
export PATH=$SPARK_HOME/bin:$PATH

echo
echo
echo "Starting Spark with "
echo "spark-shell --master yarn --driver-memory 4G --executor-memory 4G \ "
echo "    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \ "
echo "    --conf spark.kryo.registrator=com.uebercomputing.mailrecord.MailRecordRegistrator \ "
echo "    --conf spark.kryoserializer.buffer.mb=128 \ "
echo "    --conf spark.kryoserializer.buffer.max.mb=512 \ "
echo "    --jars mailrecord-utils-0.9.0-SNAPSHOT-shaded.jar\ "
echo "    --driver-java-options "-Dlog4j.configuration=log4j.properties" "
echo
echo
echo "Have fun!"

spark-shell --master yarn --driver-memory 4G --executor-memory 4G \
    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
    --conf spark.kryo.registrator=com.uebercomputing.mailrecord.MailRecordRegistrator \
    --conf spark.kryoserializer.buffer.mb=128 \
    --conf spark.kryoserializer.buffer.max.mb=512 \
    --jars mailrecord-utils-0.9.0-SNAPSHOT-shaded.jar\
    --driver-java-options "-Dlog4j.configuration=log4j.properties"

