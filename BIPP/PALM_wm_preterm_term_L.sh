#!/bin/bash

palm -i ./L.sulc.10k.shape.gii \
     -m ./L.DKatlas.10k.mask.shape.gii \
     -i ./L.thickness_corr.10k.shape.gii \
     -m ./L.DKatlas.10k.mask.shape.gii \
     -i ./L.white_corr_va.10k.shape.gii \
     -m ./L.DKatlas.10k.mask.shape.gii \
     -s ./L_average.midthickness.10k.surf.gii \
     ./L_average.midthickness_corr_va.10k.shape.gii \
     -d ./design.mat \
     -t ./design.con \
     -o ./group_comp_SAfromwm/L_Term_Preterm \
     -T \
     -tfce2d \
     -precision double \
     -logp \
     -corrcon \
     -corrmod \
     -fdr \
     -approx gamma