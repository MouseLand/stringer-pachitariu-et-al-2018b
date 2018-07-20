# stringer-pachitariu-et-al-2018b
Code to analyze recordings of 10,000 neurons in response to 2,800 natural images presented twice

This code produces the figures from Stringer, Pachitariu et al, 2018b:
Carsen Stringer, Marius Pachitariu, Nicholas Steinmetz, Matteo Carandini, Kenneth D. Harris. *High-dimensional geometry of population responses in visual cortex*

It relies on data deposited on figshare at:

Carsen Stringer, Marius Pachitariu, Nicholas Steinmetz, Matteo Carandini, Kenneth D. Harris Recordings of ten thousand neurons in visual cortex in response to 2,800 natural images. (link)

Here's the data description.

The datasets to produce all the main figures are available. The script 'process_data.m' is the main processing script. Set useGPU=0 if you do not have a GPU. The calls to the figure functions live in 'make_figs.m'.

### How to load the data into python
```
import scipy.io as sio
import numpy as np
mt = sio.loadmat('natimg2800_M160825_MP027_2016-12-14.mat')

### stimulus responses
spks = mt[‘Fsp’]                   # neurons by timepoints

med = mt[‘med’]                 # cell centers (X Y Z)
# cell statistics
mt[‘stat’][0]     # first cell’s stats
mt[‘stat’][0][‘npix’]       # one example field, tells you how pixels make up the cell
```
