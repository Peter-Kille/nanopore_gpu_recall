#!/bin/bash
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=8      #
#SBATCH --mem=16000
 
echo "Some Usable Environment Variables:"
echo "================================="
echo "hostname=$(hostname)"
echo "\$SLURM_JOB_ID=${SLURM_JOB_ID}"
echo "\$SLURM_NTASKS=${SLURM_NTASKS}"
echo "\$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}"
echo "\$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}"
echo "\$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}"
echo "\$SLURM_MEM_PER_NODE=${SLURM_MEM_PER_NODE}"
 
# Write this script to into my  output file (good for reproducibility)
cat $0

### CONVERT TO FASTQ ######

module load BEDTools/2.31.1-GCC-14.3.0
#loop for all files in primertrimdir that end in .bam 
for file in ${primertrimdir}/*.bam; do
 
name=$(basename ${file} | cut -f1 -d.)
 
bedtools bamtofastq -i "${primertrimdir}/${name}.bam" -fq "${fastqdir}/${name}.fastq"
pigz -p ${SLURM_CPUS_PER_TASK} -9 "${fastqdir}/${name}.fastq"
 
done

module unload BEDTools/2.31.1-GCC-14.3.0
