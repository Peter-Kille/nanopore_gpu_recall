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

if [ -d "${miniforgedir}" ] && [ "$(find "${miniforgedir}" -mindepth 1 | head -n 1)" ]; then
        echo  "downloaded"
else

# install miniforge (python) before you can create emu environment
cd ${workdir}/miniforgedir/

curl -LO https://github.com/conda-forge/miniforge/releases/download/24.7.1-0/Miniforge3-Linux-x86_64.sh

bash Miniforge3-Linux-x86_64.sh -b -p miniforge_env

source miniforge_env/bin/activate
rm Miniforge3-Linux-x86_64.sh
mamba create --name py37 python=3.7
source miniforge_env/bin/activate py37
python -V
mamba install -c default -c bioconda -c conda-forge emu
conda install emu
emu --version

#to exit
conda deactivate
fi

#to activate software in other modules/scripts - remember to loose the # and place at begining of module/script
#source ${workdir}/miniforgedir/miniforge_env/bin/activate py37

