#!/bin/bash

palm -i ./R.sulc.10k.shape.gii \
     -m ./R.DKatlas.10k.mask.shape.gii \
     -i ./R.thickness_corr.10k.shape.gii \
     -m ./R.DKatlas.10k.mask.shape.gii \
     -i ./R.white_corr_va.10k.shape.gii \
     -m ./R.DKatlas.10k.mask.shape.gii \
     -s ./R_average.midthickness.10k.surf.gii \
     ./R_average.midthickness_corr_va.10k.shape.gii \
     -d ./design.mat \
     -t ./design.con \
     -o ./group_comp_SAfromwm/R_Term_Preterm \
     -T \
     -tfce2d \
     -precision double \
     -logp \
     -corrcon \
     -corrmod \
     -fdr \
     -approx gamma