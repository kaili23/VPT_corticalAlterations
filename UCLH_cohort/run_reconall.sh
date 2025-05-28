#! /bin/bash

export SUBJECTS_DIR=/data/B_UCCHILD/UCCHILD_reconall6
cat /data/B_UCCHILD/subject_list.txt |parallel --jobs 8 recon-all -s {} -i {}.nii.gz -all