#!/bin/bash

roiNames=`jq -r '.roiNames' config.json`
intersect_options=`jq -r '.intersect_type' config.json`
rois=`jq -r '.rois' config.json`

intersect_options=($intersectOptions)

tracks=(`ls *track*.tck`)

roiArray=()
while read -r line; do
	roiArray+=("$line")
done <<< "$roiNames"

mkdir ./tmp/ ./track/

for (( it=0; it<${#tracks[@]}; ++it ));
do
	echo "track ${it}"
	for (( irn=0; irn<${#roiArray[@]}; ++irn ));
	do
		intersect=${intersect_options[$irn]}
		tmparray=(${roiArray[$irn]})
		if [[ ${#tmparray[@]} -gt 1 ]];  then
			roi_path=""
			for j in ${tmparray[*]}
			do
				roi_path=$roi_path" `echo ${rois}/ROI$j.nii.gz`"
			done
			mrcalc ${roi_path} -max tmp.nii.gz -force
			roi_path="./tmp.nii.gz"
			tmpstr=`echo ${tmparray[*]}`
			roi_string=`echo ${tmpstr// /_}`
			echo ${roi_string}
		else
			roi_path="${rois}/ROI${tmparray}.nii.gz"
			roi_string=${tmparray}
		fi

		if [[  ${intersect} == 'not' ]]; then
			inv_line='-inverse'
			out_name="./tmp/${tracks[$it]%%.tck}_not_${roi_string}.tck"
		else
			inv_line=''
			out_name="./tmp/${tracks[$it]%%.tck}_${roi_string}.tck"
		fi

		tckedit ${tracks[$it]} -include ${roi_path} -ends_only ${inv_line} ${out_name}
		track_info=`tckinfo ${out_name} -count`
		count=`echo ${track_info} | sed 's/.*actual count in file: //'`
		if [[ ${count} -eq 0 ]]; then
			rm -rf ${out_name}
		fi
	done
done

# cleanup
rm -rf `echo ${tracks[*]}`
mv tmp/* ./
rm -rf tmp *.nii.gz

# merge tcks into single tck
tcks=`ls *track*.tck`
tckedit ${tcks} ./track/track.tck

# final check
if [ ! -f ./track/track.tck ]; then
	echo "something went wrong. check derivatives and logs"
	exit 1
else
	echo "segmentation complete. creating wmc structure"
	exit 0
fi
