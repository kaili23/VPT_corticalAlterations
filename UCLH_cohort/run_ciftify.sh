#!/bin/bash


# Function to process each subject
process_subject() {
    local subject_name=$1
    echo "Processing subject: $subject_name"

    # Set the ciftify work directory
    CIFTIFY_WORK_DIR="/data/B_UCCHILD/UCCHILD_ciftify6"

    # Set the FreeSurfer subjects directory
    FS_SUBJECTS_DIR="/data/B_UCCHILD/UCCHILD_reconall6"
    
    ciftify_recon_all --ciftify-work-dir "$CIFTIFY_WORK_DIR" --fs-subjects-dir "$FS_SUBJECTS_DIR" "$subject_name"
}


export -f process_subject

# Run the process_subject function in parallel
cat /data/B_UCCHILD/subject_list.txt | parallel -j 6 process_subject
