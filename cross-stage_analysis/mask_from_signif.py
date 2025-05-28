import nibabel as nib
import numpy as np
import os

path='/data/BVPT_ALLanalysis/palm_analysis_final1074/groupcomp1074_afterCombat/group_comp'
hemispheres=['L', 'R']


for hemi in hemispheres:

    file1=os.path.join(path, f'{hemi}_Term_Preterm_tfce_tstat_mcfwep_m1_c1.shape.gii')
    file2=os.path.join(path, f'{hemi}_Term_Preterm_tfce_tstat_mcfwep_m1_c2.shape.gii')
    output_file = os.path.join(path, f'{hemi}_Term_Preterm_tfce_tstat_mcfwep_m1_mask.shape.gii')

    data1=nib.load(file1).darrays[0].data
    data2=nib.load(file2).darrays[0].data

    mask=np.where((data1 > 1.6) | (data2 > 1.6), 1, 0)

    mask_data_array=nib.gifti.GiftiDataArray(data=mask, intent='NIFTI_INTENT_SHAPE', datatype='NIFTI_TYPE_INT32', encoding='ASCII')
    new_img=nib.GiftiImage(darrays=[mask_data_array])

    nib.save(new_img, output_file)



for hemi in hemispheres:

    file1=os.path.join(path, f'{hemi}_Term_Preterm_tfce_tstat_mcfwep_m2_c1.shape.gii')
    file2=os.path.join(path, f'{hemi}_Term_Preterm_tfce_tstat_mcfwep_m2_c2.shape.gii')
    output_file = os.path.join(path, f'{hemi}_Term_Preterm_tfce_tstat_mcfwep_m2_mask.shape.gii')

    data1=nib.load(file1).darrays[0].data
    data2=nib.load(file2).darrays[0].data

    mask=np.where((data1 > 1.6) | (data2 > 1.6), 1, 0)

    mask_data_array=nib.gifti.GiftiDataArray(data=mask, intent='NIFTI_INTENT_SHAPE', datatype='NIFTI_TYPE_INT32', encoding='ASCII')
    new_img=nib.GiftiImage(darrays=[mask_data_array])

    nib.save(new_img, output_file)




for hemi in hemispheres:

    file1=os.path.join(path, f'{hemi}_Term_Preterm_tfce_tstat_mcfwep_m3_c1.shape.gii')
    file2=os.path.join(path, f'{hemi}_Term_Preterm_tfce_tstat_mcfwep_m3_c2.shape.gii')
    output_file = os.path.join(path, f'{hemi}_Term_Preterm_tfce_tstat_mcfwep_m3_mask.shape.gii')

    data1=nib.load(file1).darrays[0].data
    data2=nib.load(file2).darrays[0].data

    mask=np.where((data1 > 1.6) | (data2 > 1.6), 1, 0)

    mask_data_array=nib.gifti.GiftiDataArray(data=mask, intent='NIFTI_INTENT_SHAPE', datatype='NIFTI_TYPE_INT32', encoding='ASCII')
    new_img=nib.GiftiImage(darrays=[mask_data_array])

    nib.save(new_img, output_file)