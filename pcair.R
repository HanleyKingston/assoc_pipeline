#! /usr/bin/env Rscript
library(argparser)
library(magrittr)

argp <- arg_parser("Run PC-AiR") %>%
  add_argument("gds_file", help = "GDS file") %>%
  add_argument("kin_file", help = "Kinship matrix") %>%
  add_argument("div_file", help = "") %>%
  add_argument("--variant_id", help = "File with vector of variant IDs") %>%
  add_argument("--sample_id", help = "File with vector of sample IDs") %>%
  add_argument("--out_prefix", help = "Prefix for output files",
               default = "") %>%
  add_argument("--kin_thresh", help = "Kinship threshold for pcair",
               default = 2 ^ (-9 / 2)) %>%
  add_argument("--div_thresh", help = "Divergence threshold for pcair",
               default = -2 ^ (-9 / 2)) %>%
  add_argument("--num_core", help = "number of cores")

argv <- parse_args(argp)

library(SeqArray)
library(GENESIS)

sessionInfo()
print(argv)

gds <- seqOpen(argv$gds_file)

if (!is.na(argv$variant_id)) {
  variant_id <- readRDS(argv$variant_id)
} else {
  variant_id <- NULL
}
if (!is.na(argv$sample_id)) {
  sample_id <- readRDS(argv$sample_id)
} else {
  sample_id <- NULL
}

kin <- readRDS(argv$kin_file)
div <- readRDS(argv$div_file)


mypcair <- pcair(gds, kinobj = kin, kin.thresh = as.numeric(argv$kin_thresh),
                 divobj = div, snp.include = variant_id,
                 sample.include = sample_id,
                 div.thresh = as.numeric(argv$div_thresh),
                 num.cores = as.numeric(argv$num_core))

saveRDS(mypcair, paste0(argv$out_prefix, "pcair.rds"))
saveRDS(mypcair$vectors, paste0(argv$out_prefix, "pcair_pcs.rds"))
saveRDS(mypcair$unrels, paste0(argv$out_prefix, "pcair_unrels.rds"))
saveRDS(mypcair$rels, paste0(argv$out_prefix, "pcair_rels.rds"))
