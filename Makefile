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

.PHONY : all
all : small large

# Small sample analyses
.PHONY : small
small : ./output/small_samp/bfp.csv

./output/small_samp/bfp.csv : ./analysis/small_samp.R
	mkdir -p ./output/rout
	mkdir -p ./output/small_samp
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

# Large sample analyses
.PHONY : large
large : ./output/large_samp/bf_large.pdf

./output/large_samp/ldf.RDS : ./analysis/large_samp.R
	mkdir -p ./output/rout
	mkdir -p ./output/large_samp
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

./output/large_samp/bf_large.pdf : ./analysis/large_plot.R ./output/large_samp/ldf.RDS
	mkdir -p ./output/rout
	mkdir -p ./output/large_samp
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout
