#!/bin/bash

palm -i ./left.sulc.10k.shape.gii \
     -m ./L.DKatlas.dHCP.10k.mask.shape.gii \
     -i ./left.thickness_corr.10k.shape.gii \
     -m ./L.DKatlas.dHCP.10k.mask.shape.gii \
     -i ./left.wm_va_corr.10k.shape.gii \
     -m ./L.DKatlas.dHCP.10k.mask.shape.gii \
     -s ./left_average.midthickness.10k.surf.gii \
     ./left_average.midthickness_va_corr.10k.shape.gii \
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