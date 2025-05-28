#!/bin/bash

palm -i ./right.sulc.10k.shape.gii \
     -m ./R.DKatlas.dHCP.10k.mask.shape.gii \
     -i ./right.thickness_corr.10k.shape.gii \
     -m ./R.DKatlas.dHCP.10k.mask.shape.gii \
     -i ./right.wm_va_corr.10k.shape.gii \
     -m ./R.DKatlas.dHCP.10k.mask.shape.gii \
     -s ./right_average.midthickness.10k.surf.gii \
     ./right_average.midthickness_va_corr.10k.shape.gii \
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