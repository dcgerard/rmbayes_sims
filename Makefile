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

## Small sample plots
small_plots = ./output/small_samp/small_bf_hist.pdf \
              ./output/small_samp/small_bfp_hex.pdf \
              ./output/small_samp/small_monotone_box.pdf \
              ./output/small_samp/tab_extreme_bf.tex

## Large sample plots
large_plots = ./output/large_samp/qqpvalue.pdf \
              ./output/large_samp/bf_large.pdf \
              ./output/large_samp/time_large.pdf \
              ./output/large_samp/bf_sensitive.pdf \

## Raw data from Delomas et al (2021)
sturg_dat = ./data/sturg/2n_3n_Chinook_readCounts.rda \
            ./data/sturg/8n_12n_sturgeon_readCounts.rda \
            ./data/sturg/10n_sturgeon_readCounts.rda \
            ./data/sturg/white_sturgeon_genos.zip

## Get nmat for sturgeon data
sturg_n = ./output/sturg/nmat_updog.RDS \
          ./output/sturg/nmat_delo.RDS \
          ./output/sturg/sturg_updog.RDS

## Final sturgeno plots
sturg_plots = ./output/sturg/sturg_bfhist.pdf \
              ./output/sturg/sturg_snps.tex \
              ./output/sturg/sturg_bias_hist.pdf \
              ./output/sturg/sturg_twofits.pdf \
              ./output/sturg/sturg_bf_vs_p.pdf

## read-counts used from Shirasawa et al (2017)
count_shir = ./output/shir/shir_size.csv \
             ./output/shir/shir_ref.csv

## Final shirasawa plots
shir_plots = ./output/shir/shir_bf_hist.pdf \
             ./output/shir/shir_bf_scatter.pdf \
             ./output/shir/shir_bad_tab.tex

## Comparing GL to S1 in Shirasawa Data
s1_plots = ./output/shir/s1_compare/s1_snps.pdf \
           ./output/shir/s1_compare/s1_badsnp.tex \
           ./output/shir/s1_compare/s1_g0.pdf

## Plots in GL simulations
gl_plots = ./output/gl/gl_consist.pdf \
           ./output/gl/bf_compare_null.pdf \
           ./output/gl/bf_compare_alt.pdf \
           ./output/gl/gl_box_gibbs.pdf \
           ./output/gl/gl_time.pdf

## run all scripts
.PHONY : all
all : small large shir sturg gl

# Small sample analyses
.PHONY : small
small : $(small_plots)

./output/small_samp/bfp.csv : ./analysis/small/small_samp.R
	mkdir -p ./output/rout
	mkdir -p ./output/small_samp
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

$(small_plots) : ./analysis/small/small_plot.R ./output/small_samp/bfp.csv
	mkdir -p ./output/rout
	mkdir -p ./output/small_samp
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

# Large sample analyses
.PHONY : large
large : $(large_plots)

./output/large_samp/ldf.RDS : ./analysis/large/large_samp.R
	mkdir -p ./output/rout
	mkdir -p ./output/large_samp
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

$(large_plots) : ./analysis/large/large_plot.R ./output/large_samp/ldf.RDS
	mkdir -p ./output/rout
	mkdir -p ./output/large_samp
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

## Data analysis using Shirasawa data
.PHONY : shir
shir : $(shir_plots) $(s1_plots)

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

./output/shir/shir_bfdf.csv : ./analysis/shir/shir_hwep.R ./output/shir/shir_nmat.csv
	mkdir -p ./output/rout
	mkdir -p ./output/sturg
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

./output/shir/bf_gl.RDS : ./analysis/shir/shir_gltest.R ./output/shir/shir_updog.RDS
	mkdir -p ./output/rout
	mkdir -p ./output/shir
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

$(shir_plots) : ./analysis/shir/shir_plot.R ./output/shir/shir_bfdf.csv ./output/shir/bf_gl.RDS
	mkdir -p ./output/rout
	mkdir -p ./output/shir
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

./output/shir/bf_s1.RDS : ./analysis/shir/shir_s1test.R ./output/shir/shir_updog.RDS
	mkdir -p ./output/rout
	mkdir -p ./output/shir
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

$(s1_plots) : ./analysis/shir/shir_compare_s1.R ./output/shir/bf_s1.RDS ./output/shir/bf_gl.RDS ./output/shir/shir_updog.RDS
	mkdir -p ./output/rout
	mkdir -p ./output/shir
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

## Data analysis of Sturgeon data from Delomas et al (2021)
.PHONY : sturg
sturg : $(sturg_plots) ./output/sturg/equi_pval_qq.pdf

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
	mkdir -p ./data/sturg/gt_genos
	7z e ./data/sturg/white_sturgeon_genos.zip -o./data/sturg/gt_genos

$(sturg_n) : ./analysis/sturg/sturg_nmat.R $(sturg_dat)
	mkdir -p ./output/rout
	mkdir -p ./output/sturg
	$(rexec) '--args nc=$(nc)' $< ./output/rout/$(basename $(notdir $<)).Rout

./output/sturg/sturg_bfdf.csv : ./analysis/sturg/sturg_bftest.R $(sturg_n)
	mkdir -p ./output/rout
	mkdir -p ./output/sturg
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

$(sturg_plots) : ./analysis/sturg/sturg_plot.R ./output/sturg/sturg_bfdf.csv
	mkdir -p ./output/rout
	mkdir -p ./output/sturg
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

./output/sturg/equi_pval_qq.pdf : ./analysis/sturg/sturg_equi_p.R ./output/sturg/sturg_bfdf.csv
	mkdir -p ./output/rout
	mkdir -p ./output/sturg
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

## Genotype likelihood simulations
.PHONY : gl
gl : $(gl_plots)

./output/gl/gldf.RDS : ./analysis/gl/gl_samp.R
	mkdir -p ./output/rout
	mkdir -p ./output/gl
	$(rexec) '--args nc=$(nc)' $< ./output/rout/$(basename $(notdir $<)).Rout

$(gl_plots) : ./analysis/gl/gl_plot.R ./output/gl/gldf.RDS
	mkdir -p ./output/rout
	mkdir -p ./output/gl
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout
