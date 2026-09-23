#!/bin/bash
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32GB             # in megabytes, unless unit explicitly stated

echo "================================="
echo "hostname=$(hostname)"
echo \$SLURM_JOB_ID=${SLURM_JOB_ID}
echo \$SLURM_NTASKS=${SLURM_NTASKS}
echo \$SLURM_NTASKS_PER_NODE=${SLURM_NTASKS_PER_NODE}
echo \$SLURM_CPUS_PER_TASK=${SLURM_CPUS_PER_TASK}
echo \$SLURM_JOB_CPUS_PER_NODE=${SLURM_JOB_CPUS_PER_NODE}
echo \$SLURM_MEM_PER_CPU=${SLURM_MEM_PER_CPU}

# Write jobscript to output file (good for reproducibility)
cat $0

source ${workdir}/miniforgedir/miniforge_env/bin/activate py37

#moves files into folders to organise by family, genus, species
mv ${reportdir}/*-genus.tsv ${reportdir}/genusdir
mv ${reportdir}/*-species.tsv ${reportdir}/speciesdir
mv ${reportdir}/*-family.tsv ${reportdir}/familydir

#combines data into a file, typically the file you will use for next steps
emu combine-outputs ${reportdir} tax_id
emu combine-outputs --counts ${reportdir} tax_id
emu combine-outputs ${reportdir} species
emu combine-outputs --counts ${reportdir} species
emu combine-outputs ${reportdir} genus
emu combine-outputs --counts ${reportdir} genus
emu combine-outputs ${reportdir} family
emu combine-outputs --counts ${reportdir} family
