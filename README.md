
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Reproduce the Analysis from Gerard (2022)

[![NSF-2132247](https://img.shields.io/badge/NSF-2132247-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=2132247)

This repo contains the scripts and instructions to reproduce the results
of Gerard (2022).

## Instructions

To run these scripts, you will need to have the latest version of R and
GNU Make.

1.  Install the appropriate R packages

    ``` r
    install.packages(c("devtools",
                       "tidyverse",
                       "bench",
                       "ggthemes",
                       "ggpubr",
                       "xtable",
                       "hexbin", 
                       "broom",
                       "patchwork",
                       "foreach",
                       "future",
                       "doFuture",
                       "rngtools",
                       "doRNG"))
    devtools::install_github("dcgerard/hwep")
    devtools::install_github("dcgerard/updog")
    ```

2.  Run `make` in the terminal.

## Session Information

    R version 4.2.0 (2022-04-22)
    Platform: x86_64-pc-linux-gnu (64-bit)
    Running under: Ubuntu 20.04.4 LTS

    Matrix products: default
    BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3
    LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/liblapack.so.3

    locale:
     [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
     [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
     [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
     [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
     [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       

    attached base packages:
    [1] stats     graphics  grDevices utils     datasets  methods   base     

    other attached packages:
     [1] doRNG_1.8.2     rngtools_1.5.2  doFuture_0.12.2 future_1.26.1  
     [5] foreach_1.5.2   patchwork_1.1.1 broom_0.8.0     hexbin_1.28.2  
     [9] xtable_1.8-4    bench_1.1.2     updog_2.1.3     hwep_2.0.0     
    [13] ggpubr_0.4.0    ggthemes_4.2.4  forcats_0.5.1   stringr_1.4.0  
    [17] dplyr_1.0.9     purrr_0.3.4     readr_2.1.2     tidyr_1.2.0    
    [21] tibble_3.1.7    ggplot2_3.3.6   tidyverse_1.3.1 devtools_2.4.3 
    [25] usethis_2.1.6  

    loaded via a namespace (and not attached):
     [1] colorspace_2.0-3         ggsignif_0.6.3           ellipsis_0.3.2          
     [4] rprojroot_2.0.3          RcppArmadillo_0.11.2.0.0 fs_1.5.2                
     [7] rstudioapi_0.13          listenv_0.8.0            rstan_2.21.5            
    [10] remotes_2.4.2            fansi_1.0.3              lubridate_1.8.0         
    [13] xml2_1.3.3               codetools_0.2-18         cachem_1.0.6            
    [16] knitr_1.39               pkgload_1.2.4            jsonlite_1.8.0          
    [19] dbplyr_2.2.0             compiler_4.2.0           httr_1.4.3              
    [22] backports_1.4.1          assertthat_0.2.1         fastmap_1.1.0           
    [25] cli_3.3.0                htmltools_0.5.2          prettyunits_1.1.1       
    [28] tools_4.2.0              gtable_0.3.0             glue_1.6.2              
    [31] Rcpp_1.0.8.3             carData_3.0-5            cellranger_1.1.0        
    [34] vctrs_0.4.1              iterators_1.0.14         xfun_0.31               
    [37] globals_0.15.1           ps_1.7.1                 brio_1.1.3              
    [40] testthat_3.1.4           rvest_1.0.2              lifecycle_1.0.1         
    [43] rstatix_0.7.0            scales_1.2.0             hms_1.1.1               
    [46] parallel_4.2.0           inline_0.3.19            yaml_2.3.5              
    [49] memoise_2.0.1            gridExtra_2.3            loo_2.5.1               
    [52] StanHeaders_2.21.0-7     stringi_1.7.6            desc_1.4.1              
    [55] pkgbuild_1.3.1           rlang_1.0.3              pkgconfig_2.0.3         
    [58] matrixStats_0.62.0       lattice_0.20-45          evaluate_0.15           
    [61] rstantools_2.2.0         processx_3.6.1           tidyselect_1.1.2        
    [64] parallelly_1.32.0        magrittr_2.0.3           R6_2.5.1                
    [67] generics_0.1.2           DBI_1.1.2                pillar_1.7.0            
    [70] haven_2.5.0              withr_2.5.0              abind_1.4-5             
    [73] modelr_0.1.8             crayon_1.5.1             car_3.0-13              
    [76] utf8_1.2.2               tzdb_0.3.0               rmarkdown_2.14          
    [79] grid_4.2.0               readxl_1.4.0             callr_3.7.0             
    [82] reprex_2.0.1             digest_0.6.29            RcppParallel_5.1.5      
    [85] stats4_4.2.0             munsell_0.5.0            sessioninfo_1.2.2       

## Acknowledgments

This material is based upon work supported by the National Science
Foundation under Grant
No. [2132247](https://www.nsf.gov/awardsearch/showAward?AWD_ID=2132247).
The opinions, findings, and conclusions or recommendations expressed are
those of the author and do not necessarily reflect the views of the
National Science Foundation.

# References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-gerard2022bayesian" class="csl-entry">

Gerard, David. 2022. “Bayesian Tests for Random Mating in
Autopolyploids.” *Unpublished Manuscript*.

</div>

</div>
