
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Reproduce the Analysis from Gerard (2022)

[![NSF-2132247](https://img.shields.io/badge/NSF-2132247-blue.svg)](https://nsf.gov/awardsearch/showAward?AWD_ID=2132247)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6993722.svg)](https://doi.org/10.5281/zenodo.6993722)

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

    R version 4.2.1 (2022-06-23)
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
     [1] doRNG_1.8.2     rngtools_1.5.2  doFuture_0.12.2 future_1.27.0  
     [5] foreach_1.5.2   patchwork_1.1.1 broom_1.0.0     hexbin_1.28.2  
     [9] xtable_1.8-4    bench_1.1.2     updog_2.1.3     hwep_2.0.0     
    [13] ggpubr_0.4.0    ggthemes_4.2.4  forcats_0.5.1   stringr_1.4.0  
    [17] dplyr_1.0.9     purrr_0.3.4     readr_2.1.2     tidyr_1.2.0    
    [21] tibble_3.1.8    ggplot2_3.3.6   tidyverse_1.3.2 devtools_2.4.4 
    [25] usethis_2.1.6  

    loaded via a namespace (and not attached):
     [1] googledrive_2.0.0        colorspace_2.0-3         ggsignif_0.6.3          
     [4] ellipsis_0.3.2           RcppArmadillo_0.11.2.0.0 fs_1.5.2                
     [7] rstudioapi_0.13          listenv_0.8.0            rstan_2.21.5            
    [10] remotes_2.4.2            fansi_1.0.3              lubridate_1.8.0         
    [13] xml2_1.3.3               codetools_0.2-18         cachem_1.0.6            
    [16] knitr_1.39               pkgload_1.3.0            jsonlite_1.8.0          
    [19] dbplyr_2.2.1             shiny_1.7.2              compiler_4.2.1          
    [22] httr_1.4.3               backports_1.4.1          assertthat_0.2.1        
    [25] fastmap_1.1.0            gargle_1.2.0             cli_3.3.0               
    [28] later_1.3.0              htmltools_0.5.3          prettyunits_1.1.1       
    [31] tools_4.2.1              gtable_0.3.0             glue_1.6.2              
    [34] Rcpp_1.0.9               carData_3.0-5            cellranger_1.1.0        
    [37] vctrs_0.4.1              iterators_1.0.14         xfun_0.32               
    [40] globals_0.16.0           ps_1.7.1                 rvest_1.0.2             
    [43] mime_0.12                miniUI_0.1.1.1           lifecycle_1.0.1         
    [46] rstatix_0.7.0            googlesheets4_1.0.1      scales_1.2.0            
    [49] hms_1.1.1                promises_1.2.0.1         parallel_4.2.1          
    [52] inline_0.3.19            yaml_2.3.5               memoise_2.0.1           
    [55] gridExtra_2.3            loo_2.5.1                StanHeaders_2.21.0-7    
    [58] stringi_1.7.8            pkgbuild_1.3.1           matrixStats_0.62.0      
    [61] rlang_1.0.4              pkgconfig_2.0.3          lattice_0.20-45         
    [64] evaluate_0.16            rstantools_2.2.0         htmlwidgets_1.5.4       
    [67] processx_3.7.0           tidyselect_1.1.2         parallelly_1.32.1       
    [70] magrittr_2.0.3           R6_2.5.1                 generics_0.1.3          
    [73] profvis_0.3.7            DBI_1.1.3                pillar_1.8.0            
    [76] haven_2.5.0              withr_2.5.0              abind_1.4-5             
    [79] modelr_0.1.8             crayon_1.5.1             car_3.1-0               
    [82] utf8_1.2.2               tzdb_0.3.0               rmarkdown_2.14          
    [85] urlchecker_1.0.1         grid_4.2.1               readxl_1.4.0            
    [88] callr_3.7.1              reprex_2.0.1             digest_0.6.29           
    [91] httpuv_1.6.5             RcppParallel_5.1.5       stats4_4.2.1            
    [94] munsell_0.5.0            sessioninfo_1.2.2       

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
Autopolyploids.” *bioRxiv*. <https://doi.org/10.1101/2022.08.11.503635>.

</div>

</div>
