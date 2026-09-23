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

#this if statment won't download the database it has been already downloaded
if [ -d "${EMU_DATABASE_DIR}" ] && [ "$(ls -A "${EMU_DATABASE_DIR}")" ]; then
	echo  "database downloaded"
else
#to activate software in future - remember to loose thsource 
source "${workdir}/miniforgedir/miniforge_env/bin/activate" py37

#install osfclien for download
pip install osfclient

cd "${EMU_DATABASE_DIR}"

#download and decompress database
osf -p 56uf7 fetch osfstorage/emu-prebuilt/emu.tar
tar -xvf emu.tar
fi
