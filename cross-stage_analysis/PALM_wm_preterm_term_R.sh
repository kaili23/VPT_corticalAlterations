#!/bin/bash

palm -i ./BIPP_UCCHILD_dHCP.right.sulc_removesites.10k.shape.gii \
     -m ./R.DKatlas.10k.mask.shape.gii \
     -i ./BIPP_UCCHILD_dHCP.right.thickness_corr_removesites.10k.shape.gii \
     -m ./R.DKatlas.10k.mask.shape.gii \
     -i ./BIPP_UCCHILD_dHCP.right.whiteSA_corr_removesites.10k.shape.gii \
     -m ./R.DKatlas.10k.mask.shape.gii \
     -s ./BIPP_UCCHILD_dHCP.right_average.midthickness.10k.surf.gii \
     ./BIPP_UCCHILD_dHCP.right_average.midthickness_corr_va.10k.shape.gii \
     -d ./design.mat \
     -t ./design.con \
     -o ./group_comp/R_Term_Preterm \
     -T \
     -tfce2d \
     -precision double \
     -logp \
     -corrcon \
     -corrmod \
     -fdr \
     -approx gamma