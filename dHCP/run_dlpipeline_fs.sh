#!/bin/bash
python run_pipeline.py --in_dir='/data/dHCP_neonatal/dHCP_volume886/' \
                       --out_dir='/data/dHCP_neonatal/dHCP_template_generation/dhcp_surface_fs886/' \
                       --T2='_T2w_restore_brain.nii.gz' \
                       --sphere_proj='fs' \
                       --device='cuda:0'