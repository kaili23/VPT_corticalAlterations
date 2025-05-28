#!/bin/bash

export SUBJECTS_DIR=/data/BIPP_dhcprecon/BIPP_T1reconall6

# Set the ciftify work directory
CIFTIFY_WORK_DIR="/data/BIPP_dhcprecon/BIPP_T1ciftify6"

# Set the FreeSurfer subjects directory
FS_SUBJECTS_DIR="/data/BIPP_dhcprecon/BIPP_T1reconall6"

# Iterate through subjects and run ciftify_recon_all
while IFS= read -r subject_name; do
    echo "Processing subject: $subject_name"

    subject_dir="/data/BIPP_dhcprecon/BIPP_T1reconall6/${subject_name}"
    
    ciftify_recon_all --ciftify-work-dir "$CIFTIFY_WORK_DIR" --fs-subjects-dir "$FS_SUBJECTS_DIR" "$subject_name"
done < "/data/BIPP_dhcprecon/subject_list.txt"
