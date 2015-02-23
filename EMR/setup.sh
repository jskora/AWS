#!/bin/sh

# First we need to get a few things from S3

# A "fixed" version of Spark (Thanks Markus!!!!)
echo "pulling down a patched version of Spark (Thanks Markus!!!!)"
wget --quiet https://s3.amazonaws.com/morris-datasets/ENRON/demo/spark-1.2.1.tar.gz 
tar xf /home/hadoop/spark-1.2.1.tar.gz
sleep 2

# The dataset
echo "pulling down the dataset"
wget --quiet https://s3.amazonaws.com/morris-datasets/ENRON/demo/enron.avro 
sleep1
hdfs dfs -put ~/enron.avro

# some utilities
echo "pulling down some utilities (Thanks Markus!!!! Again!!!)"
wget --quiet https://s3.amazonaws.com/morris-datasets/ENRON/demo/log4j.properties 
wget --quiet https://s3.amazonaws.com/morris-datasets/ENRON/demo/mailrecord-utils-0.9.0-SNAPSHOT-shaded.jar 

# Hack to add variables 
wget -P ~/ --quiet https://raw.githubusercontent.com/notjasonmorris/AWS/master/EMR/bashrc
mv -f ~/bashrc ~/.bashrc
export SPARK_HOME=/home/hadoop/spark-1.2.1-hadoop2.4
export PATH=$SPARK_HOME/bin:$PATH

echo
echo
echo "Starting Spark with "
echo "spark-shell --master yarn-client --driver-memory 4G --executor-memory 4G --num-executors 3 --executor-cores 2\ "
echo "    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \ "
echo "    --conf spark.kryo.registrator=com.uebercomputing.mailrecord.MailRecordRegistrator \ "
echo "    --conf spark.kryoserializer.buffer.mb=128 \ "
echo "    --conf spark.kryoserializer.buffer.max.mb=512 \ "
echo "    --jars mailrecord-utils-0.9.0-SNAPSHOT-shaded.jar,./.versions/2.4.0/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.4.0.jar \ "
echo "    --driver-java-options "-Dlog4j.configuration=log4j.properties" "
echo
echo
echo "Have fun!"

spark-shell --master yarn-client --driver-memory 4G --executor-memory 4G --num-executors 3 --executor-cores 2\
    --conf spark.serializer=org.apache.spark.serializer.KryoSerializer \
    --conf spark.kryo.registrator=com.uebercomputing.mailrecord.MailRecordRegistrator \
    --conf spark.kryoserializer.buffer.mb=128 \
    --conf spark.kryoserializer.buffer.max.mb=512 \
    --jars mailrecord-utils-0.9.0-SNAPSHOT-shaded.jar,.versions/2.4.0/share/hadoop/mapreduce/hadoop-mapreduce-client-core-2.4.0.jar\
    --driver-java-options "-Dlog4j.configuration=log4j.properties"
