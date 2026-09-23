#!/usr/bin/env Rscript
metadata<-Sys.getenv("metadata")
inputdir<-Sys.getenv("reportdir")
outputdir<-Sys.getenv("ranacapadir")
sourcedir<-Sys.getenv("sourcedir")

########## Installing packages #############

# Install packages if missing
packages <- c("dplyr", "readr", "tidyr")

for (pkg in packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

############################################################
#calls packages
library(dplyr) 
library(readr) 
library(tidyr) 

#formats file so it is compatable with ranacapa in R
ranacapa_combined_counts <- read_tsv(file.path(inputdir, "emu-combined-tax_id-counts.tsv")) %>%
#orders columns
  select( superkingdom, phylum, class, order, family, genus, species, everything(), -tax_id ) %>%
#replaces unknown to nothing/blank space in columns which are characters 
  mutate(across(
    where(is.character), ~ ifelse(is.na(.) | . %in% c("NA", "unknown"), "", .) )) %>%
#replaces NA with a 0 for columns which are numeric 
  mutate(across( .cols = 
    -c(1:7), .fns = ~ if (is.numeric(.)) replace_na(., 0) else .
  )) %>% 
#rounds number e.g. 20.6 to 26
  mutate(across(where(is.numeric), round)) %>%
#merges column superkingdom to species into 1 column called sum.taxonamy separated by a ; 
    unite("sum.taxonomy", 1:7, sep = ";", remove =TRUE) %>%
#removes last two lines typically summary lines 
    slice(1:(n() - 2))

#saves result
write_delim(ranacapa_combined_counts,
            file = file.path(outputdir, "ranacapa_combined_counts.tsv"),
            delim = "\t", col_names = TRUE)

#formats metadata file to a tsv file and saves
metadata <- read_csv(file.path(sourcedir, metadata)) 

write_delim(metadata,
            file = file.path(outputdir, "ranacapa_metadata.tsv"),
            delim = "\t", col_names = TRUE)
