#!/bin/bash

# Source config script
source arguments.config
source folder.config
source programs.config

# Step 1: recall_demux
# dorado - recall and demux
# CORE PARAMETERS: sourcedir, 
# INPUT: pod5dir
# WORK: basecall
# OUTPUT: null
# PROCESS - File transfer
sbatch -d singleton --error="${log}/1_recall-demux_%J.err" --output="${log}/1_recall-demux_%J.out" --job-name=${runname} --partition=${gpu} "${moduledir}/1_recall-demux.sh"

samples=$( tail -n +2 ${sourcedir}/${metadata} | cut -f1 -d,)

export samples
export sample_array=($samples)
sample_number=${#sample_array[@]}
sample_number=$(($sample_number - 1))

# Step 2: convert to fastq
# CORE PARAMETERS: modules, fastqdir, workdir
# INPUT: basecalldir
# WORK: fastqdir
# OUTPUT: null
# PROCESS - bedtoools
sbatch -d singleton --error="${log}/2_recall-fastq_%J.err" --output="${log}/2_recall-fastq%J.out" --job-name=${runname} --partition=${node} "${moduledir}/2_recall-fastq.sh"

# Step 3: Renaming files
# CORE PARAMETERS: modules, fastqdir, renameddir
# INPUT: fastqdir
# WORK: 
# OUTPUT: null
# PROCESS - 
sbatch -d singleton --error="${log}/3_recall-rename%J.err" --output="${log}/3_recall-rename%J.out"  --job-name=${runname} --partition=${node} "${moduledir}/3_recall-rename.sh"  


# Step 4: FastQC 
# CORE PARAMETERS: modules, renameddir, qcdir
# INPUT: renameddir
# WORK: qcdir
# OUTPUT: null
# PROCESS - FastQC raw data
sbatch -d singleton --error="${log}/4_recall-QC%J.err" --output="${log}/4_recall-QC%J.out" --job-name=${runname} --partition=${node} "${moduledir}/4_recall-QC.sh"
