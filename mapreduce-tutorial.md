# MapReduce Tutorial


## Create and test the mapper and reducer programs


* create a project folder in your home folder, let's call it `mapreduce`

```bash
cd ~ 
mkdir mapreduce
```

* create python2.7 environmnet ```conda create -n py27 python=2.7```

* switch to python2.7 environment ```conda activate py27```

---

## Create Mapper and Reducer to count words

* start vscode in the mapreduce folder

```bash
cd ~/mapreduce
code .
```

* create mapper.py by copying and pasting the following code:

```python
  #!/usr/bin/env python

# for every word received print the word, and count 1
# Hadoop will sort these words, and stream result susing
# stdin to the reducer.
import sys

for line in sys.stdin: # look through data that is piped into this program
    line = line.strip()
    line = line.lower()
    words = line.split()

    for word in words:
        if len(word) == 0:
            print '%s\t%s' % ("UNKOWN", 1)
        else:
            print '%s\t%s' % (word, 1)
```

* start a terminal in the local folder. This can be done within vscode by pressing `ctrl+``, or starting the terminal program and navigating to the folder.

* Change permissions of mapper.py to executable `chmod +x mapper.py`

* Test mapper.py by running `cat test.txt | ./mapper.py`. This should produce a list of words and the number 1 for each word.

* Using the shell's built in sort command, add a sort (to similar shuffle and sort that mapreduce will do) by running `cat test.txt | ./mapper.py | sort`

* in vscode, create reducer.py by copying and pasting the following code:

```python

#!/usr/bin/env python

from operator import itemgetter
import sys

current_word = None
current_count = 0
word = None
for line in sys.stdin: # read all stdin line by line (like it was a file)

    # strip and split the word count pair    
    line = line.strip()
    word, count = line.split('\t')
    count = int(count)
    
    # if we have a new word
    if current_word != word and current_word != None:
        print '%s\t%s' % (current_word, current_count)
        current_count = 0
    
    current_word = word
    current_count += count

# since at the end of our loop, we haven't seen a 'transition' from one word to another
# we need to print this here.
print '%s\t%s' % (current_word, current_count)
```

* Change reducer.py to executable `chmod +x reducer.py`

* Test reducer.py by running `cat test.txt | ./mapper.py | sort | ./reducer.py`

---

## Setup Mapreduce job in Cloudera Hadoop


*  log in to the CyberHub VM
*  Change directory to Workspace 'cd ~/Workspace`
*  Clone the MapReduceDemo repo `git clone https://github.com/prof-tcsmith/MapReduceDemo.git`
*  Copy reducer.py, mapper.py, test.txt, and run-mr-job.sh to the Cloudera container shared folder
```bash
cp -p reducer.py ~/Workspace/bd24-STUDENT/Cloudera/shared-folder
cp -p mapper.py ~/Workspace/bd24-STUDENT/Cloudera/shared-folder
cp -p test.txt ~/Workspace/bd24-STUDENT/Cloudera/shared-folder
cp -p run-mr-job.sh ~/Workspace/bd24-STUDENT/Cloudera/shared-folder
```
* Run the run-mr-job.sh script `./run-mr-job.sh`
> NOTE: This script contains the following code
> ```bash
> #!/usr/bin/env bash
> mkdir /mapreduce
> chmod 777 /mapreduce
> cp mapper.py /mapreduce
> cp reducer.py /mapreduce
> hdfs dfs -mkdir /mapreduce
> hdfs dfs -copyFromLocal test.txt /mapreduce
> cd /mapreduce
> /usr/bin/hadoop jar /usr/lib/hadoop-mapreduce/hadoop-streaming.jar \
    -files mapper.py,reducer.py \
    -input /mapreduce/test.txt \
    -output /mapreduce/output01 \
    -mapper mapper.py \
    -reducer reducer.py
> ```
  
After running, you will see something the following output.

```
[root@quickstart mapreduce]# /usr/bin/hadoop jar /usr/lib/hadoop-mapreduce/hadoop-streaming.jar \
>     -files mapper.py,reducer.py \
>     -input /mapreduce/test.txt \
>     -output /mapreduce/output01 \
>     -mapper mapper.py \
>     -reducer reducer.py
packageJobJar: [] [/usr/jars/hadoop-streaming-2.6.0-cdh5.7.0.jar] /tmp/streamjob5479037920909289490.jar tmpDir=null
24/04/13 15:49:29 INFO client.RMProxy: Connecting to ResourceManager at /0.0.0.0:8032
24/04/13 15:49:29 INFO client.RMProxy: Connecting to ResourceManager at /0.0.0.0:8032
24/04/13 15:49:29 INFO mapred.FileInputFormat: Total input paths to process : 1
24/04/13 15:49:30 INFO mapreduce.JobSubmitter: number of splits:2
24/04/13 15:49:30 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1713022680746_0001
24/04/13 15:49:30 INFO impl.YarnClientImpl: Submitted application application_1713022680746_0001
24/04/13 15:49:31 INFO mapreduce.Job: The url to track the job: http://quickstart.cloudera:8088/proxy/application_1713022680746_0001/
24/04/13 15:49:31 INFO mapreduce.Job: Running job: job_1713022680746_0001
24/04/13 15:49:37 INFO mapreduce.Job: Job job_1713022680746_0001 running in uber mode : false
24/04/13 15:49:37 INFO mapreduce.Job:  map 0% reduce 0%
24/04/13 15:49:42 INFO mapreduce.Job:  map 50% reduce 0%
24/04/13 15:49:43 INFO mapreduce.Job:  map 100% reduce 0%
24/04/13 15:49:47 INFO mapreduce.Job:  map 100% reduce 100%
24/04/13 15:49:47 INFO mapreduce.Job: Job job_1713022680746_0001 completed successfully
24/04/13 15:49:47 INFO mapreduce.Job: Counters: 49
	File System Counters
		FILE: Number of bytes read=107
		FILE: Number of bytes written=351123
		FILE: Number of read operations=0
		FILE: Number of large read operations=0
		FILE: Number of write operations=0
		HDFS: Number of bytes read=291
		HDFS: Number of bytes written=23
		HDFS: Number of read operations=9
		HDFS: Number of large read operations=0
		HDFS: Number of write operations=2
	Job Counters 
		Launched map tasks=2
		Launched reduce tasks=1
		Data-local map tasks=2
		Total time spent by all maps in occupied slots (ms)=5247
		Total time spent by all reduces in occupied slots (ms)=2756
		Total time spent by all map tasks (ms)=5247
		Total time spent by all reduce tasks (ms)=2756
		Total vcore-seconds taken by all map tasks=5247
		Total vcore-seconds taken by all reduce tasks=2756
		Total megabyte-seconds taken by all map tasks=5372928
		Total megabyte-seconds taken by all reduce tasks=2822144
	Map-Reduce Framework
		Map input records=4
		Map output records=11
		Map output bytes=79
		Map output materialized bytes=113
		Input split bytes=204
		Combine input records=0
		Combine output records=0
		Reduce input groups=3
		Reduce shuffle bytes=113
		Reduce input records=11
		Reduce output records=3
		Spilled Records=22
		Shuffled Maps =2
		Failed Shuffles=0
		Merged Map outputs=2
		GC time elapsed (ms)=51
		CPU time spent (ms)=1600
		Physical memory (bytes) snapshot=993382400
		Virtual memory (bytes) snapshot=4232572928
		Total committed heap usage (bytes)=2472542208
	Shuffle Errors
		BAD_ID=0
		CONNECTION=0
		IO_ERROR=0
		WRONG_LENGTH=0
		WRONG_MAP=0
		WRONG_REDUCE=0
	File Input Format Counters 
		Bytes Read=87
	File Output Format Counters 
		Bytes Written=23
24/04/13 15:49:47 INFO streaming.StreamJob: Output directory: /mapreduce/output01

```
* Investigate results

These will be found on your hdfs file location /user/cloudera/output

```bash
hdfs dfs -cat /user/cloudera/output/part-00000
```

