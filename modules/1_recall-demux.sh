#!/bin/bash
#SBATCH --nodes=1              # number of nodes to use
#SBATCH --tasks-per-node=1     #
#SBATCH --cpus-per-task=8      #
#SBATCH --mem=60000
#SBATCH --gres=gpu:1
##SBATCH --mail-user= # email address used for event notification
##SBATCH --mail-type=end                                   # email on job end
##SBATCH --mail-type=fail                                  # email on job failure
 
 
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

# load singularity module
module load Apptainer/1.5.1-GCCcore-14.3.0
 
#https://hub.docker.com/r/nanoporetech/dorado
IMAGENAME=dorado2-1-1.sif
IMAGEDIR=/mnt/ecotox/GROUP-smbpk/resources/singularities/

mkdir -p /tmp/${USER}/apptainer/working

cp ${IMAGEDIR}/${IMAGENAME} /tmp/${USER}/apptainer/working/${IMAGENAME}

# set folders to bind into container
export BINDS="${BINDS},${pipedir}:${pipedir}"
 
############# SOURCE COMMANDS ##################################
cat > ${workdir}/dorado_${SLURM_JOB_ID}.sh <<EOF
 
###### RECALL USING NEW ALGOITHUM ######## 
dorado basecaller "/models/dna_r10.4.1_e8.2_400bps_sup@v5.2.0" \
        ${sourcedir}/${datapod5} \
         --kit-name ${barcode_np} > ${basecalldir}/basecall_all.bam
 
####### DEMUX #############
 
dorado demux --output-dir ${demuxdir}/ --no-classify ${basecalldir}/basecall_all.bam

done

EOF
 
################ END OF SOURCE COMMANDS ######################
 
apptainer exec --nv --contain --bind ${BINDS} --pwd ${workdir} /tmp/${USER}/apptainer/working/${IMAGENAME} bash ${workdir}/dorado_${SLURM_JOB_ID}.sh

