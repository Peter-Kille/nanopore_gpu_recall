# deploy_recall
For demux-ing, converting to fastq, renaming and qc-ing from pod5 files

```
Usage: ./deploy_recall --runname NAME --node NODE --datapod5 FOLDER --metadata FILE

Options:
  -r  --runname       REQUIRED: Run name or deployment name - should be unique
  -n  --node          REQUIRED: Avalible partition / hpc queue (epyc, defq, epyc_ssd) for step
  -d  --datapod5      REQUIRED: Location/File of pod5 files you want to run
  -m  --metadata      REQUIRED: Location/File of metadata
  -w, --workdir       Optional: working dir - default is current dir /work/
  -g  --gpu           Optional: Avalible gpu parttition, only currently one so default is gpu
  -k  --kit_np        Optional: Nanopore kit/equipment default is SQK-LSK114
  -b  --barcode_np    Optional: Nanopore barcode default is EXP-PBC001
  -h, --help          Show this help message
```
Current end files are .zip and .html fastqc files

## Metadata file
The meta data file must be a .csv with the first column your sample name and the 2nd column barcode numbers e.g
Sample_name_1,barcode01
Remember when uploading an excel .csv use dos2unix to change the file the windows formatted to compatable with linux
**Most errors occur do to wrong Metadata formatting**

## Module order
deploy script runs modules in order 1 to 8:
* 1_recall-demux.sh
* 2_recall-fastq.sh
* 3_recall-rename.sh
* 4_recall-QC.sh

Steps 1-4 demux, fastq and qc the files. Also renames the files based off the Metadata file.

```
update container

# Convert docker image to sif
  
# Enter interactive node on gpu
srun -c 8 --mem=16G -p gpu --gres=gpu:1 --pty bash
  
# Load latest apptainer module
module load Apptainer/1.5.1-GCCcore-14.3.0
 
# Point the apptainer cache directory to tmp
# (default is $HOME, which is inconvenient for many HPC systems)
# Using the tmp folder is the fastest and most reliable method for cache
mkdir -p /tmp/$USER/apptainer/cache
export APPTAINER_CACHEDIR=/tmp/$USER/apptainer/cache
export APPTAINER_TMPDIR=/tmp/$USER/apptainer/cache
  
# Create a working folder on tmp to store local image
# You can use /mnt/scratch for this but using tmp is faster and more reliable, just remember to copy image to folder at end
mkdir -p /tmp/$USER/apptainer/working
cd /tmp/$USER/apptainer/working
  
# Pull dorado from Docker Hub and store as .sif image
apptainer pull dorado_lastest.sif docker://nanoporetech/dorado
 
 

  # Tranfer copy of container to nodelete
cp /tmp/$USER/apptainer/working/dorado.v0.9.1.sif /mnt/scratch45/nodelete/${USER}/

#most recent
apptainer exec --nv --contain -B $(pwd -P) dorado_latest.sif dorado --version
mv dorado_latest.sif dorado2-1-1.sif
apptainer exec --nv --contain -B $(pwd -P) dorado2-1-1.sif list-models 
```

The models in the current version (2.1.1) are:

```
# Simplex models for general basecalling
- dna_r10.4.1_e8.2_400bps_sup@v5.2.0
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0
- dna_r10.4.1_e8.2_400bps_sup@v4.3.0
- dna_r10.4.1_e8.2_400bps_hac@v6.0.0
- dna_r10.4.1_e8.2_400bps_hac@v5.2.0
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0
- dna_r10.4.1_e8.2_400bps_hac@v4.3.0
- dna_r10.4.1_e8.2_400bps_fast@v5.2.0
- dna_r10.4.1_e8.2_400bps_fast@v5.0.0
- dna_r10.4.1_e8.2_400bps_fast@v4.3.0
- dna_r10.4.1_e8.2_400bps_fast@v4.2.0
- dna_r10.4.1_e8.2_apk_sup@v5.0.0
- rna004_sup@v6.0.0
- rna004_hac@v6.0.0
- rna004_fast@v6.0.0
- rna004_130bps_sup@v5.3.0
- rna004_130bps_sup@v5.2.0
- rna004_130bps_sup@v5.1.0
- rna004_130bps_sup@v5.0.0
- rna004_130bps_sup@v3.0.1
- rna004_130bps_hac@v5.3.0
- rna004_130bps_hac@v5.2.0
- rna004_130bps_hac@v5.1.0
- rna004_130bps_hac@v5.0.0
- rna004_130bps_hac@v3.0.1
- rna004_130bps_fast@v5.3.0
- rna004_130bps_fast@v5.2.0
- rna004_130bps_fast@v5.1.0
- rna004_130bps_fast@v5.0.0
- rna004_130bps_fast@v3.0.1
# Stereo models for duplex basecalling
- dna_r10.4.1_e8.2_5khz_stereo@v1.5
# Remora models for modification-aware basecalling
- dna_r10.4.1_e8.2_400bps_sup@v5.2.0_6mA@v1
- dna_r10.4.1_e8.2_400bps_sup@v5.2.0_5mC_5hmC@v2
- dna_r10.4.1_e8.2_400bps_sup@v5.2.0_5mCG_5hmCG@v2
- dna_r10.4.1_e8.2_400bps_sup@v5.2.0_4mC_5mC@v1
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_6mA@v3
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_6mA@v2
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_6mA@v1
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_5mC_5hmC@v3
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_5mC_5hmC@v2.0.1
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_5mC_5hmC@v1
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_5mCG_5hmCG@v3
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_5mCG_5hmCG@v2.0.1
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_5mCG_5hmCG@v1
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_4mC_5mC@v3
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_4mC_5mC@v2
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_4mC_5mC@v1
- dna_r10.4.1_e8.2_400bps_sup@v4.3.0_6mA@v2
- dna_r10.4.1_e8.2_400bps_sup@v4.3.0_5mC_5hmC@v1
- dna_r10.4.1_e8.2_400bps_sup@v4.3.0_5mCG_5hmCG@v1
- dna_r10.4.1_e8.2_400bps_hac@v6.0.0_6mA@v1
- dna_r10.4.1_e8.2_400bps_hac@v6.0.0_5mC_5hmC@v1
- dna_r10.4.1_e8.2_400bps_hac@v6.0.0_5mCG_5hmCG@v1
- dna_r10.4.1_e8.2_400bps_hac@v6.0.0_4mC_5mC@v1
- dna_r10.4.1_e8.2_400bps_hac@v5.2.0_6mA@v1
- dna_r10.4.1_e8.2_400bps_hac@v5.2.0_5mC_5hmC@v2
- dna_r10.4.1_e8.2_400bps_hac@v5.2.0_5mCG_5hmCG@v2
- dna_r10.4.1_e8.2_400bps_hac@v5.2.0_4mC_5mC@v1
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_6mA@v3
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_6mA@v2
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_6mA@v1
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_5mC_5hmC@v3
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_5mC_5hmC@v2
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_5mC_5hmC@v1
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_5mCG_5hmCG@v3
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_5mCG_5hmCG@v2
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_5mCG_5hmCG@v1
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_4mC_5mC@v3
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_4mC_5mC@v2
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_4mC_5mC@v1
- dna_r10.4.1_e8.2_400bps_hac@v4.3.0_6mA@v2
- dna_r10.4.1_e8.2_400bps_hac@v4.3.0_5mC_5hmC@v1
- dna_r10.4.1_e8.2_400bps_hac@v4.3.0_5mCG_5hmCG@v1
- dna_r10.4.1_e8.2_400bps_fast@v4.2.0_5mCG_5hmCG@v2
- rna004_sup@v6.0.0_pseU_2OmeU@v1
- rna004_sup@v6.0.0_m6A_DRACH@v1
- rna004_sup@v6.0.0_m5C_2OmeC@v1
- rna004_sup@v6.0.0_inosine_m6A_2OmeA@v1
- rna004_sup@v6.0.0_2OmeG@v1
- rna004_hac@v6.0.0_pseU@v1
- rna004_hac@v6.0.0_m6A_DRACH@v1
- rna004_hac@v6.0.0_m5C@v1
- rna004_hac@v6.0.0_inosine_m6A@v1
- rna004_130bps_sup@v5.3.0_pseU_2OmeU@v1
- rna004_130bps_sup@v5.3.0_m6A_DRACH@v1
- rna004_130bps_sup@v5.3.0_m5C_2OmeC@v1
- rna004_130bps_sup@v5.3.0_inosine_m6A_2OmeA@v1
- rna004_130bps_sup@v5.3.0_2OmeG@v1
- rna004_130bps_sup@v5.2.0_pseU_2OmeU@v1
- rna004_130bps_sup@v5.2.0_m6A_DRACH@v1
- rna004_130bps_sup@v5.2.0_m5C_2OmeC@v1
- rna004_130bps_sup@v5.2.0_inosine_m6A_2OmeA@v1
- rna004_130bps_sup@v5.2.0_2OmeG@v1
- rna004_130bps_sup@v5.1.0_pseU@v1
- rna004_130bps_sup@v5.1.0_m6A_DRACH@v1
- rna004_130bps_sup@v5.1.0_m5C@v1
- rna004_130bps_sup@v5.1.0_inosine_m6A@v1
- rna004_130bps_sup@v5.0.0_pseU@v1
- rna004_130bps_sup@v5.0.0_m6A_DRACH@v1
- rna004_130bps_sup@v5.0.0_m6A@v1
- rna004_130bps_sup@v3.0.1_m6A_DRACH@v1
- rna004_130bps_hac@v5.3.0_pseU@v1
- rna004_130bps_hac@v5.3.0_m6A_DRACH@v1
- rna004_130bps_hac@v5.3.0_m5C@v1
- rna004_130bps_hac@v5.3.0_inosine_m6A@v1
- rna004_130bps_hac@v5.2.0_pseU@v1
- rna004_130bps_hac@v5.2.0_m6A_DRACH@v1
- rna004_130bps_hac@v5.2.0_m5C@v1
- rna004_130bps_hac@v5.2.0_inosine_m6A@v1
- rna004_130bps_hac@v5.1.0_pseU@v1
- rna004_130bps_hac@v5.1.0_m6A_DRACH@v1
- rna004_130bps_hac@v5.1.0_m5C@v1
- rna004_130bps_hac@v5.1.0_inosine_m6A@v1
- rna004_130bps_hac@v5.0.0_pseU@v1
- rna004_130bps_hac@v5.0.0_m6A_DRACH@v1
- rna004_130bps_hac@v5.0.0_m6A@v1
# Models for assembly polishing
- dna_r10.4.1_e8.2_400bps_sup@v5.2.0_polish_rl_mv
- dna_r10.4.1_e8.2_400bps_sup@v5.2.0_polish_rl
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_polish_rl_mv
- dna_r10.4.1_e8.2_400bps_sup@v5.0.0_polish_rl
- dna_r10.4.1_e8.2_400bps_sup@v4.3.0_polish
- dna_r10.4.1_e8.2_400bps_sup@v4.2.0_polish
- dna_r10.4.1_e8.2_400bps_polish_bacterial_methylation_v5.0.0
- dna_r10.4.1_e8.2_400bps_hac@v6.0.0_polish_rl_mv
- dna_r10.4.1_e8.2_400bps_hac@v6.0.0_polish_rl
- dna_r10.4.1_e8.2_400bps_hac@v5.2.0_polish_rl_mv
- dna_r10.4.1_e8.2_400bps_hac@v5.2.0_polish_rl
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_polish_rl_mv
- dna_r10.4.1_e8.2_400bps_hac@v5.0.0_polish_rl
- dna_r10.4.1_e8.2_400bps_hac@v4.3.0_polish
- dna_r10.4.1_e8.2_400bps_hac@v4.2.0_polish
# Models for read error correction
- herro-v1.1
# Models available for small variant analysis
- dna_r10.4.1_e8.2_400bps_hac@v6.0.0_smallvar@v1.0
- dna_r10.4.1_e8.2_400bps_hac@v5.2.0_smallvar@v1.0
```
