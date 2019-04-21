#!/bin/bash

# set -e

OUTPUT_DIR="test_output_files"
CORRECT_DIR="correct_outputs"
DIFF_DIR="diff_outputs"
TIMEOUT=10

# create output directory
rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

# create diff directory
rm -rf $DIFF_DIR
mkdir $DIFF_DIR

kill_simv() {
	for pid in `lsof +D . | grep "simv" | awk {'print $2'}` ; 
	do 
		kill $pid; 
	done
}

for file in test_progs/*.s;
do
	# get correct test name
	file=$(echo $file | cut -d'.' -f1)
	file=$(echo $file | cut -d'/' -f2)

	echo "Assembling $file"
	# assemble test case
	./vs-asm < test_progs/$file.s > program.mem
	echo "Running $file"

	# run test case
	make clean simv
	timeout $TIMEOUT make all
	echo "Saving $file output"

	# kill simv if its still running
	kill_simv
	
	# save the output
	cp writeback.out $OUTPUT_DIR/$file.writeback.out
	cp pipeline.out $OUTPUT_DIR/$file.pipeline.out
	cp program.out $OUTPUT_DIR/$file.program.out

done

message="GRADE OUTPUT"

message="$message\nChecking for correctness"

message="$message\nChecking for correct memory..."

wrong=0
total=0

for file in $CORRECT_DIR/*.program.out;
do
	# get correct test name
	file=$(echo $file | cut -d'/' -f2)

	if [ -f $OUTPUT_DIR/$file  ]
	then
		# check memory differences
		grep "@@@" $OUTPUT_DIR/$file > $DIFF_DIR/$file.output.grep
		grep "@@@" $CORRECT_DIR/$file > $DIFF_DIR/$file.correct.grep
		diff $DIFF_DIR/$file.output.grep $DIFF_DIR/$file.correct.grep > $DIFF_DIR/$file

		# if file is not empty, then output is incorrect
		if [ -s $DIFF_DIR/$file ]
		then
			message="$message\n\t$file \t\t\tFAILED"
			wrong=`expr $wrong + 1`
		else
			message="$message\n\t$file \t\t\tPASSED"
		fi
		total=`expr $total + 1`
	fi
done

correct=`expr $total - $wrong`
message="$message\nPASSED: $correct/$total"

wrong=0
total=0

message="$message\nChecking for correct writeback..."

for file in $CORRECT_DIR/*.writeback.out;
do
	# get correct test name
	file=$(echo $file | cut -d'/' -f2) 

	if [ -f $OUTPUT_DIR/$file ]
	then
		# check differences
		diff $OUTPUT_DIR/$file $CORRECT_DIR/$file > $DIFF_DIR/$file
		# if file is not empty, then output is incorrect
		if [ -s $DIFF_DIR/$file  ]
		then
			message="$message\n\t$file \t\t\tFAILED"
			wrong=`expr $wrong + 1`
		else
			message="$message\n\t$file \t\t\tPASSED"
		fi
	fi
	total=`expr $total + 1`
done

correct=`expr $total - $wrong`
message="$message\nPASSED $correct/$total"
echo -e $message | tee grade.txt
