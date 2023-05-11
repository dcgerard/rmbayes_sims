
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
    Running under: Ubuntu 22.04.2 LTS

    Matrix products: default
    BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3
    LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.20.so

    locale:
     [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
     [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
     [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
     [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
     [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       

    attached base packages:
    [1] stats     graphics  grDevices datasets  utils     methods   base     

    other attached packages:
     [1] doRNG_1.8.6     rngtools_1.5.2  doFuture_1.0.0  future_1.32.0  
     [5] foreach_1.5.2   patchwork_1.1.2 broom_1.0.4     hexbin_1.28.3  
     [9] xtable_1.8-4    bench_1.1.3     updog_2.1.3     hwep_2.0.2     
    [13] ggpubr_0.6.0    ggthemes_4.2.4  lubridate_1.9.2 forcats_1.0.0  
    [17] stringr_1.5.0   dplyr_1.1.2     purrr_1.0.1     readr_2.1.4    
    [21] tidyr_1.3.0     tibble_3.2.1    ggplot2_3.4.2   tidyverse_2.0.0
    [25] devtools_2.4.5  usethis_2.1.6  

    loaded via a namespace (and not attached):
     [1] matrixStats_0.63.0       fs_1.6.2                 rstan_2.26.18           
     [4] tools_4.2.1              profvis_0.3.8            backports_1.4.1         
     [7] utf8_1.2.3               R6_2.5.1                 colorspace_2.1-0        
    [10] urlchecker_1.0.1         withr_2.5.0              gridExtra_2.3           
    [13] tidyselect_1.2.0         prettyunits_1.1.1        processx_3.8.1          
    [16] curl_5.0.0               compiler_4.2.1           cli_3.6.1               
    [19] scales_1.2.1             callr_3.7.3              StanHeaders_2.26.18     
    [22] digest_0.6.31            rmarkdown_2.21           pkgconfig_2.0.3         
    [25] htmltools_0.5.5          parallelly_1.35.0        sessioninfo_1.2.2       
    [28] fastmap_1.1.1            htmlwidgets_1.6.2        rlang_1.1.1             
    [31] rstudioapi_0.14          shiny_1.7.4              generics_0.1.3          
    [34] jsonlite_1.8.4           car_3.1-2                inline_0.3.19           
    [37] magrittr_2.0.3           loo_2.6.0                Rcpp_1.0.10             
    [40] munsell_0.5.0            fansi_1.0.4              abind_1.4-5             
    [43] lifecycle_1.0.3          stringi_1.7.12           yaml_2.3.7              
    [46] carData_3.0-5            pkgbuild_1.4.0           grid_4.2.1              
    [49] parallel_4.2.1           listenv_0.9.0            promises_1.2.0.1        
    [52] crayon_1.5.2             lattice_0.20-45          miniUI_0.1.1.1          
    [55] hms_1.1.3                knitr_1.42               ps_1.7.5                
    [58] pillar_1.9.0             ggsignif_0.6.4           stats4_4.2.1            
    [61] future.apply_1.10.0      codetools_0.2-18         pkgload_1.3.2           
    [64] rstantools_2.3.1         glue_1.6.2               evaluate_0.21           
    [67] RcppArmadillo_0.12.2.0.0 V8_4.3.0                 remotes_2.4.2           
    [70] renv_0.17.3              BiocManager_1.30.20      RcppParallel_5.1.7      
    [73] vctrs_0.6.2              tzdb_0.3.0               httpuv_1.6.10           
    [76] gtable_0.3.3             assertthat_0.2.1         cachem_1.0.8            
    [79] xfun_0.39                mime_0.12                rstatix_0.7.2           
    [82] later_1.3.1              iterators_1.0.14         memoise_2.0.1           
    [85] timechange_0.2.0         globals_0.16.2           ellipsis_0.3.2          

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

Gerard, David. 2022. “Bayesian Tests for Random Mating in Polyploids.”
*bioRxiv*. <https://doi.org/10.1101/2022.08.11.503635>.

</div>

</div>
