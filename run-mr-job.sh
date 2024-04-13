#!/usr/bin/env bash
mkdir /mapreduce
chmod 777 /mapreduce
cp mapper.py /mapreduce
cp reducer.py /mapreduce
hdfs dfs -mkdir /mapreduce
hdfs dfs -copyFromLocal test.txt /mapreduce
cd /mapreduce
/usr/bin/hadoop jar /usr/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -files mapper.py,reducer.py \
    -input /mapreduce/test.txt \
    -output /mapreduce/output01 \
    -mapper mapper.py \
    -reducer reducer.py
