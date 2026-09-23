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

##### RENAME files #####
#Loop for all files in fastqdir
for file in ${fastqdir}/*; do 

name=$(basename ${file} | cut -f1 -d.)

bcname=$(echo ${name} | cut -f3 -d_)
#copies file from fastqdir into renameddir
cp ${fastqdir}/${name}.fastq.gz ${renameddir}/${bcname}.fastq.gz

done
#uses metadata file to match barcode number with sample name
#by saving the first column as 'sample' and the second as 'barcode'
tail -n +2 ${sourcedir}/${metadata} | while IFS="," read -r sample barcode; do
#renames the files by replaces the with barcode x with its adjacent sample name
mv ${renameddir}/${barcode}.fastq.gz ${renameddir}/${sample}.fastq.gz
done

