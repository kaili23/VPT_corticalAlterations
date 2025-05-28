#!/bin/bash
python run_pipeline.py --in_dir='/data/BIPP_eprimedata/ePrime_T2orig/' \
                       --out_dir='/data/BIPP_eprimedata/surface-based-analysis/ePrime_T2dhcpdl_fs/' \
                       --T2='_T2.nii.gz' \
                       --sphere_proj='fs' \
                       --device='cuda:0'