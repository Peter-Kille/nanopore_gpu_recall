# deploy_recall
For demux-ing, converting to fasq, renaming and qc-ing from 16S pod5 files

```
Usage: ./deploy_recall --runname NAME --node NODE --datapod5 FOLDER --primer FILE --metadata FILE

Options:
  -r  --runname       REQUIRED: Run name or deployment name - should be unique
  -n  --node          REQUIRED: Avalible partition / hpc queue (epyc, defq, epyc_ssd) for step
  -d  --datapod5      REQUIRED: Location/File of pod5 files you want to run
  -p  --primer        REQUIRED: Location/File of the primers
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
* 5_emu-install
* 6_emu-database
* 7A_emu-array.sh
* 7B_emu-combine.sh
* 8_SARTools.sh (runs script ranacapa_conversion.r)

Steps 1-4 demux, fastq and qc the files. Also renames the files based off the Metadata file.
Steps 5-7 uses emu to taxonmaticlly classify the files
Step 8 formats the emu combined tax files into a combatable format for ranacapa R plugin (for visualisation)


