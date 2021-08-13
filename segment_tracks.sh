#!/bin/bash

## This function will take in wmc datatype with it's associated tractogram and segment subtracks based on input rois and desired
## intersect options. This uses mrtrix3's tckedit functionality. This function does the segmentation.

## If you use this, please cite mrtrix3:
## Tournier, J.-D.; Smith, R. E.; Raffelt, D.; Tabbara, R.; Dhollander, T.; Pietsch, M.; Christiaens, D.; Jeurissen, B.; Yeh, C.-H. & Connelly, A. MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation. NeuroImage, 2019, 202, 116137

# set configurable inputs
roiNames=`jq -r '.roiNames' config.json`
intersect_options=`jq -r '.intersect_type' config.json`
inverse=`jq -r '.inverse' config.json`
endpoints_only=`jq -r '.endpoints_only' config.json`
rois=`jq -r '.rois' config.json`

# need to set this as a multiline array
intersect_options=($intersect_options)

# identify the parent tracks
tracks=(`ls *track*.tck`)

# this makes for loops with multi lines possible and much easier
roiArray=()
while read -r line; do
	roiArray+=("$line")
done <<< "$roiNames"

# make directories
mkdir ./tmp/ ./track/

# catch if inverse was set as true. currently setting as boolean, which limits things. but will come back to this later
if [[ ${inverse} == 'true' ]]; then
	inv_line='-inverse'
	inv_string="inverse"
else
	inv_line=''
	inv_string="not_inverse"
fi

# catch if endpoints only was set as true. currently setting as boolean, which limits things. but will come back to this later
if [[ ${endpoints_only} == 'true' ]]; then
	endpoint_line='-ends_only'
	endpoint_string="endpoints_only"
else
	endpoint_line=''
	endpoint_string="traverse"
fi

# loop through tracks
for (( it=0; it<${#tracks[@]}; ++it ));
do
	echo "track ${it}"
	# loop through roi lines
	for (( irn=0; irn<${#roiArray[@]}; ++irn ));
	do
		# set rois as tmparray to easier parse. also set intersect option for this roi
		tmparray=(${roiArray[$irn]})
		intersect=${intersect_options[$irn]}

		# capture what the intersect option should be for the 
		if [[  ${intersect} == 'exclude' ]]; then
			reg_line='-exclude'
			reg_string="exclude"
		else
			reg_line='-include'
			reg_string="include"
		fi

		# need to identify when multiple rois are desired. if so, will iteratively go through each roi and extract streamlines. if just a single
		# roi, will just do the simple extraction once
		if [[ ${#tmparray[@]} -gt 1 ]]; then
			filelist=()
			for (( j=0; j<${#tmparray[@]}; ++j ));
			do
				if [[ ${j} -eq 0 ]]; then
					tmptrack=${tracks[$it]%%.tck}
					out_name="./tmp/${tracks[$it]%%.tck}_roioptions_${reg_string}_inverseoptions_${inv_string}_rois_${tmparray[$j]}"
				else
					tmptrack=${filelist[$j-1]}
					out_name="${filelist[$j-1]}_${tmparray[$j]}"
				fi

				roi_path="${rois}/ROI${tmparray[$j]}.nii.gz"

				[ ! -f ${out_name}.tck ] && tckedit ${tmptrack}.tck ${reg_line} ${roi_path} ${inv_line} ${endpoint_line} ${out_name}.tck

				if [[ ${j} -gt 0 ]]; then
					[ -f ${tmptrack}.tck ] && rm -rf ${tmptrack}.tck
				fi

				filelist+=("${out_name}")
			done
		else
			roi_path="${rois}/ROI${tmparray}.nii.gz"
			out_name="./tmp/${tracks[$it]%%.tck}_roioptions_${reg_string}_inverseoptions_${inv_string}_rois_${tmparray}.tck"

			[ ! -f ${out_name} ] && tckedit ${tracks[$it]} ${reg_line} ${roi_path} ${inv_line} ${endpoint_line} ${out_name}
		fi
	done
done

# remove parent tracks, move segmented tracks to pwd and remove tmp dir
if [ "$(ls -A ./tmp/)" ]; then
	rm -rf `echo ${tracks[*]}`
	mv tmp/* ./
	rm -rf tmp
fi

# identify all the tracks with non-zero streamline counts. remove those who have zero streamlines. this will make wmc generation much easier
tracks=`ls *.tck`
for out_name in ${tracks}
do
	track_info=`tckinfo ${out_name} -count`
	count=`echo ${track_info} | sed 's/.*actual count in file: //'`
	if [[ ${count} -eq 0 ]]; then
		rm -rf ${out_name}
	fi
done

# merge final tcks into single tck
tcks=`ls *track*.tck`
[ ! -f ./track/track.tck ] && tckedit ${tcks} ./track/track.tck
[ ! -f track_names.txt ] && echo ${tcks} >> track_names.txt

# final check to make sure the final tck was made. if not will exit here
if [ ! -f ./track/track.tck ]; then
	echo "something went wrong. check derivatives and logs"
	exit 1
else
	echo "segmentation complete. creating wmc structure"
	exit 0
fi
