#!/usr/bin/env python3

import os
import glob
import json
import numpy as np
import nibabel as nib
from dipy.io.streamline import load_tractogram
import scipy.io as sio
from matplotlib import cm

# open configurable inputs
with open('config.json') as config_f:
    config = json.load(config_f)
    ref = config["reference_anatomy"]

# load reference anatomy
reference_anat = nib.load(ref)

# identify tracks
with open('track_names.txt','r') as track_names_f:
    tracks = track_names_f.read()

tracks = tracks.split(' ')
tracks = [ f.replace('\n','') for f in tracks ]
track_names = np.array([ f.replace('.tck','') for f in tracks ],dtype=object)

# load tractogram and extract streamlines
streamline_index = []
streams = []
count = 0
tg = {}
tractsfile = []

for i in range(len(tracks)):
    tg[i] = load_tractogram(tracks[i],reference_anat,bbox_valid_check=False)
    streams = streams + list(tg[i].streamlines)
    streamline_index = streamline_index + [ i+1 for f in range(len(tg[i].streamlines)) ]
    count = count + len(tg[i].streamlines)

streamlines = np.zeros([count],dtype=object)
for i in range(len(streamlines)):
    streamlines[i] = streams[i].round(2)

# create json structure
for i in range(len(tg)):
    color = list(cm.PuOr(i+1))[0:3]
    count = len(tg[i].streamlines)
    jsonfibers = streamlines[[f for f in range(len(streamline_index)) if streamline_index[f] == i+1]]
    outfibers = []
    for j in range(len(jsonfibers)):
        outfibers.append(np.transpose(jsonfibers[j]).tolist())

    with open ('wmc/tracts/'+str(i+1)+'.json', 'w') as outfile:
        jsonfile = {'name': track_names[i], 'color': color, 'coords': outfibers}
        json.dump(jsonfile, outfile)

    tractsfile.append({"name": track_names[i], "color": color, "filename": str(i+1)+'.json'})

with open ('wmc/tracts/tracts.json', 'w') as outfile:
    json.dump(tractsfile, outfile, separators=(',', ': '), indent=4)

# save classification structure
print("saving classification.mat")
sio.savemat('wmc/classification.mat', { "classification": {"names": track_names, "index": streamline_index }})

