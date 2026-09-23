#!/bin/bash
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=8      #
#SBATCH --mem=60000
 
 
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

###### QC Stages ######

module load fastqc/v0.11.9

export _JAVA_OPTIONS="-Xmx4g"

#fastqc for all files in renameddir
for file in ${renameddir}/*.gz; do

fastqc --threads 2 ${file} -o ${qcdir}/

done

module unload fastqc/v0.11.9

module load multiqc/1.9

multiqc ${renameddir}/ -o ${qcdir}

module purge
