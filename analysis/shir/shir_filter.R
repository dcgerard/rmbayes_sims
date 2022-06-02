#################################
## Filter Shirasawa SNPs and extract counts
#################################

library(VariantAnnotation)
shir <- readVcf("./data/shir/KDRIsweetpotatoXushu18S1LG2017.vcf")

## Get counts ----
refmat <- geno(shir)$RD
altmat <- geno(shir)$AD
sizemat <- altmat + refmat

## Do filtering ----
allele_freq <- rowMeans(refmat / sizemat, na.rm = TRUE)
good_af <- allele_freq > 0.1 & allele_freq < 0.9
good_size <- rowMeans(sizemat, na.rm = TRUE) > 100
good_miss <- rowMeans(is.na(sizemat)) < 0.5

refmat <- refmat[good_af & good_size & good_miss, ]
altmat <- altmat[good_af & good_size & good_miss, ]
sizemat <- sizemat[good_af & good_size & good_miss, ]

write.csv(x = refmat, file = "./output/shir/shir_ref.csv")
write.csv(x = sizemat, file = "./output/shir/shir_size.csv")
