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

for f in ${renameddir}/*.fastq.gz
do
base=$(basename $f |cut -f1 -d.)

echo ${base}

emu abundance ${renameddir}/${base}.fastq.gz \
        --threads ${SLURM_CPUS_PER_TASK} \
        --output-dir ${reportdir} \
        --output-basename ${base} \
        --keep-counts \
        --db ${EMU_DATABASE_DIR}

emu collapse-taxonomy ${reportdir}/${base}_rel-abundance.tsv genus
emu collapse-taxonomy ${reportdir}/${base}_rel-abundance.tsv species
emu collapse-taxonomy ${reportdir}/${base}_rel-abundance.tsv family

done

mv ${reportdir}/*-genus.tsv ${reportdir}/genusdir
mv ${reportdir}/*-species.tsv ${reportdir}/speciesdir
mv ${reportdir}/*-family.tsv ${reportdir}/familydir

emu combine-outputs ${reportdir} tax_id
emu combine-outputs --counts ${reportdir} tax_id
emu combine-outputs ${reportdir} species
emu combine-outputs --counts ${reportdir} species
emu combine-outputs ${reportdir} genus
emu combine-outputs --counts ${reportdir} genus
emu combine-outputs ${reportdir} family
emu combine-outputs --counts ${reportdir} family
