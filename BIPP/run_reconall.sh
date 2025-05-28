#! /bin/bash

export SUBJECTS_DIR=/data/BIPP_dhcprecon/BIPP_T1reconall6
cat /data/BIPP_dhcprecon/subject_list.txt |parallel --jobs 8 recon-all -s {} -i {}.nii.gz -all