#!/bin/bash

Usage() {
    echo "align_to_dHCP_NewTemplates.sh <topdir> <subjid> <age> <templateage> <templatespherepath> <tempTotemp> <pre_rotation> <config>"
    echo "Script to align native surfaces with template space & resample native surfaces with template topology."
    echo "Input arguments: "
    echo " 1. topdir: Top directory where subject directories are located."
    echo " 2. subjid: Subject ID."
    echo " 3. age: Age in weeks gestation, determining which week of the spatio-temporal template the data will first be mapped to."
    echo " 4. templateage: Target age for the median template."
    echo " 5. templatespherepath: Path to the dHCP surface template directory."
    echo " 6. tempTotemp: Directory for storing template-to-template results."
    echo " 7. pre_rotation: Text file containing the rotational transform between MNI and FS_LR space (e.g., file rotational_transforms/week40_toFS_LR_rot.%hemi%.txt)."
    echo " 8. config: Path to the base configuration file."
    echo "Output: 1) Surface registrations; 2) Native GIFTIs resampled with template topology"
}


if [ "$#" -lt 8 ]; then
    echo "$#"
    Usage
    exit
fi



topdir=$1;shift
subjid=$1;shift
age=$1;shift
templateage=$1;shift
templatespherepath=$1;shift
tempTotemp=$1;shift
pre_rotation=$1;shift
config=$1; shift



echo "registration and resample for $subjid $age"
mkdir -p ${topdir}/${subjid}/32KLR_dHCP40space
########## DEFINE PATHS TO VARIABLES ##########

# native spheres
native_sphereL=${topdir}/${subjid}/${subjid}_hemi-left_sphere.surf.gii
native_sphereR=${topdir}/${subjid}/${subjid}_hemi-right_sphere.surf.gii

# native spheres rotated into FS_LR space
native_rot_sphereL=${topdir}/${subjid}/${subjid}_hemi-left_sphere.rot.surf.gii
native_rot_sphereR=${topdir}/${subjid}/${subjid}_hemi-right_sphere.rot.surf.gii


# native data
native_dataL=${topdir}/${subjid}/${subjid}_hemi-left_sulc.shape.gii
native_dataR=${topdir}/${subjid}/${subjid}_hemi-right_sulc.shape.gii

# surface template files - assumes directory structure consistent with dHCP surface template
templatesphereL=$templatespherepath/week${age}_left_LR.32k.sphere.surf.gii
templatesphereR=$templatespherepath/week${age}_right_LR.32k.sphere.surf.gii
templatedataL=$templatespherepath/week${age}_left_sulc_LR.32k.shape.gii
templatedataR=$templatespherepath/week${age}_right_sulc_LR.32k.shape.gii 

# pre-rotations
pre_rotationL="$pre_rotation/week40_toFS_LR_rot.L.txt"
pre_rotationR="$pre_rotation/week40_toFS_LR_rot.R.txt"


########## ROTATE LEFT AND RIGHT HEMISPHERES INTO APPROXIMATE ALIGNMENT WITH SURFACE TEMPLATE SPACE ##########

wb_command -surface-apply-affine $native_sphereL $pre_rotationL ${native_rot_sphereL} 
wb_command -surface-modify-sphere ${native_rot_sphereL} 100 ${native_rot_sphereL} -recenter
wb_command -surface-apply-affine $native_sphereR $pre_rotationR ${native_rot_sphereR} 
wb_command -surface-modify-sphere ${native_rot_sphereR} 100 ${native_rot_sphereR} -recenter


########## RUN MSM NON-LINEAR ALIGNMENT TO TEMPLATE FOR LEFT AND RIGHT HEMISPHERES ##########

echo "start registration"
for hemi in left right; do

    if [ "$hemi" == "left" ]; then
      newmsm --conf=$config \
      --inmesh=$native_rot_sphereL \
      --refmesh=$templatesphereL \
      --indata=$native_dataL \
      --refdata=$templatedataL \
      --out=${topdir}/${subjid}/32KLR_dHCP40space/${subjid}_hemi-left_from-native-to-LR.week${age}_32k.

    else
      newmsm --conf=$config \
      --inmesh=$native_rot_sphereR \
      --refmesh=$templatesphereR \
      --indata=$native_dataR \
      --refdata=$templatedataR \
      --out=${topdir}/${subjid}/32KLR_dHCP40space/${subjid}_hemi-right_from-native-to-LR.week${age}_32k.
    fi

done

echo "completed registration"



# need to concatenate msm warp to local template with warp from local template to median week template
if [ "$age" != "$templateage" ] ; then

   wb_command -surface-sphere-project-unproject \
         "${topdir}/${subjid}/32KLR_dHCP40space/${subjid}_hemi-left_from-native-to-LR.week${age}_32k.sphere.reg.surf.gii" \
         ${templatesphereL} \
         "$tempTotemp/dHCPtemplate_left_week${age}To${templateage}.sphere.reg.surf.gii" \
         "${topdir}/${subjid}/32KLR_dHCP40space/${subjid}_hemi-left_from-native-to-LR.week${templateage}_32k.sphere.reg.surf.gii"

   wb_command -surface-sphere-project-unproject \
         "${topdir}/${subjid}/32KLR_dHCP40space/${subjid}_hemi-right_from-native-to-LR.week${age}_32k.sphere.reg.surf.gii" \
         ${templatesphereR} \
         "$tempTotemp/dHCPtemplate_right_week${age}To${templateage}.sphere.reg.surf.gii" \
         "${topdir}/${subjid}/32KLR_dHCP40space/${subjid}_hemi-right_from-native-to-LR.week${templateage}_32k.sphere.reg.surf.gii"

	   
else
   echo "age and template age are the same, no concatenation needed"

fi



########## RESAMPLE NATIVE SURFACES TO TEMPLATE ##########

echo "start resample"

nativedir=${topdir}/${subjid}
dhcpLR_dir=${topdir}/${subjid}/32KLR_dHCP40space

for hemi in left right ; do
	     
	template=$templatespherepath/week${templateage}_${hemi}_LR.32k.sphere.surf.gii
	cp $template $dhcpLR_dir/${subjid}_hemi-${hemi}_sphere_space-dhcpLR40.32k.surf.gii 

    transformed_sphere=${topdir}/${subjid}/32KLR_dHCP40space/${subjid}_hemi-${hemi}_from-native-to-LR.week${templateage}_32k.sphere.reg.surf.gii

    # resample surfaces
    for surf in pial wm midthickness inflated vinflated; do 

        wb_command -surface-resample $nativedir/${subjid}_hemi-${hemi}_${surf}.surf.gii $transformed_sphere $template BARYCENTRIC $dhcpLR_dir/${subjid}_hemi-${hemi}_${surf}_space-dhcpLR40.32k.surf.gii

    done 


   # resample .shape metrics
    for metric in sulc curv thickness; do 
        wb_command -metric-resample $nativedir/${subjid}_hemi-${hemi}_${metric}.shape.gii $transformed_sphere $template ADAP_BARY_AREA $dhcpLR_dir/${subjid}_hemi-${hemi}_${metric}_space-dhcpLR40.32k.shape.gii -area-surfs $nativedir/${subjid}_hemi-${hemi}_midthickness.surf.gii  $dhcpLR_dir/${subjid}_hemi-${hemi}_midthickness_space-dhcpLR40.32k.surf.gii
    done

done 

echo "finished"


