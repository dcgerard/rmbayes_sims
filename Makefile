# ADJUST THESE VARIABLES AS NEEDED TO SUIT YOUR COMPUTING ENVIRONMENT
# -------------------------------------------------------------------
# This variable specifies the number of threads to use for the
# parallelization. This could also be specified automatically using
# environment variables. For example, in SLURM, SLURM_CPUS_PER_TASK
# specifies the number of CPUs allocated for each task.
nc = 6

# R scripting front-end. Note that makeCluster sometimes fails to
# connect to a socker when using Rscript, so we are using the "R CMD
# BATCH" interface instead.
rexec = R CMD BATCH --no-save --no-restore

# AVOID EDITING ANYTHING BELOW THIS LINE
# --------------------------------------

## Raw data from Delomas et al (2021)
sturg_dat = ./data/sturg/2n_3n_Chinook_readCounts.rda \
            ./data/sturg/8n_12n_sturgeon_readCounts.rda \
            ./data/sturg/10n_sturgeon_readCounts.rda \
            ./data/sturg/white_sturgeon_genos.zip

## Get nmat for sturgeon data
sturg_n = ./output/sturg/nmat_updog.RDS \
          ./output/sturg/nmat_delo.RDS \
          ./output/sturg/sturg_updog.RDS

## read-counts used from Shirasawa et al (2017)
count_shir = ./output/shir/shir_size.csv \
             ./output/shir/shir_ref.csv

## run all scripts
.PHONY : all
all : small large shir sturg

# Small sample analyses
.PHONY : small
small : ./output/small_samp/bfp.csv

./output/small_samp/bfp.csv : ./analysis/small/small_samp.R
	mkdir -p ./output/rout
	mkdir -p ./output/small_samp
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

# Large sample analyses
.PHONY : large
large : ./output/large_samp/bf_large.pdf ./output/large_samp/time_large.pdf

./output/large_samp/ldf.RDS : ./analysis/large/large_samp.R
	mkdir -p ./output/rout
	mkdir -p ./output/large_samp
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

./output/large_samp/bf_large.pdf ./output/large_samp/time_large.pdf: ./analysis/large/large_plot.R ./output/large_samp/ldf.RDS
	mkdir -p ./output/rout
	mkdir -p ./output/large_samp
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

## Data analysis using Shirasawa data
.PHONY : shir
shir : ./output/shir/shir_nmat.csv

./data/shir/KDRIsweetpotatoXushu18S1LG2017.vcf :
	mkdir -p ./data/shir
	wget --directory-prefix=data/shir --no-clobber https://github.com/dcgerard/KDRIsweetpotatoXushu18S1LG2017/raw/main/KDRIsweetpotatoXushu18S1LG2017.vcf.gz
	7z e ./data/shir/KDRIsweetpotatoXushu18S1LG2017.vcf.gz -o./data/shir

$(count_shir) : ./analysis/shir/shir_filter.R ./data/shir/KDRIsweetpotatoXushu18S1LG2017.vcf
	mkdir -p ./output/rout
	mkdir -p ./output/shir
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

./output/shir/shir_updog.RDS : ./analysis/shir/shir_updog.R $(count_shir)
	mkdir -p ./output/rout
	mkdir -p ./output/shir
	$(rexec) '--args nc=$(nc)' $< ./output/rout/$(basename $(notdir $<)).Rout

./output/shir/shir_nmat.csv : ./analysis/shir/shir_geno.R ./output/shir/shir_updog.RDS
	mkdir -p ./output/rout
	mkdir -p ./output/shir
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout


## Data analysis of Sturgeon data from Delomas et al (2021)
.PHONY : sturg
sturg : ./output/sturg/sturg_bfdf.csv

$(sturg_dat) :
	mkdir -p ./data/sturg
	wget --directory-prefix=data/sturg --no-clobber https://datadryad.org/stash/downloads/file_stream/711274
	mv ./data/sturg/711274 ./data/sturg/10n_sturgeon_readCounts.rda
	wget --directory-prefix=data/sturg --no-clobber https://datadryad.org/stash/downloads/file_stream/711272
	mv ./data/sturg/711272 ./data/sturg/2n_3n_Chinook_readCounts.rda
	wget --directory-prefix=data/sturg --no-clobber https://datadryad.org/stash/downloads/file_stream/711273
	mv ./data/sturg/711273 ./data/sturg/8n_12n_sturgeon_readCounts.rda
	wget --directory-prefix=data/sturg --no-clobber https://datadryad.org/stash/downloads/file_stream/711275
	mv ./data/sturg/711275 ./data/sturg/white_sturgeon_genos.zip

$(sturg_n) : ./analysis/sturg/sturg_nmat.R $(sturg_dat)
	mkdir -p ./output/rout
	mkdir -p ./output/sturg
	$(rexec) '--args nc=$(nc)' $< ./output/rout/$(basename $(notdir $<)).Rout

./output/sturg/sturg_bfdf.csv : ./analysis/sturg/sturg_bftest.R $(sturg_n)
	mkdir -p ./output/rout
	mkdir -p ./output/sturg
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout
