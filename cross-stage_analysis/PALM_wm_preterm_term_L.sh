#!/bin/bash

palm -i ./BIPP_UCCHILD_dHCP.left.sulc_removesites.10k.shape.gii \
     -m ./L.DKatlas.10k.mask.shape.gii \
     -i ./BIPP_UCCHILD_dHCP.left.thickness_corr_removesites.10k.shape.gii \
     -m ./L.DKatlas.10k.mask.shape.gii \
     -i ./BIPP_UCCHILD_dHCP.left.whiteSA_corr_removesites.10k.shape.gii \
     -m ./L.DKatlas.10k.mask.shape.gii \
     -s ./BIPP_UCCHILD_dHCP.left_average.midthickness.10k.surf.gii \
     ./BIPP_UCCHILD_dHCP.left_average.midthickness_corr_va.10k.shape.gii \
     -d ./design.mat \
     -t ./design.con \
     -o ./group_comp/L_Term_Preterm \
     -T \
     -tfce2d \
     -precision double \
     -logp \
     -corrcon \
     -corrmod \
     -fdr \
     -approx gamma