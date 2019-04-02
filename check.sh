#!/bin/bash

# set -e

OUTPUT_DIR="test_output_files"
CORRECT_DIR="correct_outputs"
DIFF_DIR="diff_outputs"

# create output directory
rm -rf $OUTPUT_DIR
mkdir $OUTPUT_DIR

# create diff directory
rm -rf $DIFF_DIR
mkdir $DIFF_DIR

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
	timeout 100 make clean_pipeline simv_pipeline
	echo "Saving $file output"
	
	# save the output
	cp writeback.out $OUTPUT_DIR/$file.writeback.out
	cp pipeline.out $OUTPUT_DIR/$file.pipeline.out
	cp program.out $OUTPUT_DIR/$file.program.out

done

echo "Checking for correctness"

echo "Checking for correct memory..."

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
			echo -e "\t$file \t\t\tFAILED"
			wrong=`expr $wrong + 1`
		fi
		total=`expr $total + 1`
	fi
done

correct=`expr $total - $wrong`
echo "PASSED: $correct/$total"

wrong=0
total=0

echo "Checking for correct writeback..."

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
			echo -e "\t$file \t\t\tFAILED"
			wrong=`expr $wrong + 1`
		fi
	fi
	total=`expr $total + 1`
done

correct=`expr $total - $wrong`
echo "PASSED: $correct/$total"

