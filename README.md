# stringer-pachitariu-et-al-2018b
Code to analyze recordings of 10,000 neurons in response to 2,800 natural images presented twice

This code produces the figures from Stringer, Pachitariu et al, 2018b:
Carsen Stringer, Marius Pachitariu, Nicholas Steinmetz, Matteo Carandini, Kenneth D. Harris. *High-dimensional geometry of population responses in visual cortex*

It relies on data deposited on figshare at:

Carsen Stringer, Marius Pachitariu, Nicholas Steinmetz, Matteo Carandini, Kenneth D. Harris. *Recordings of ten thousand neurons in visual cortex in response to 2,800 natural images.* (link)

Here's the data description.

The datasets to produce all the main figures are available. The script 'process_data.m' is the main processing script. Set useGPU=0 if you do not have a GPU. The calls to the figure functions live in 'make_figs.m'.

### How to load the data into python
```
import scipy.io as sio
mt = sio.loadmat('natimg2800_M160825_MP027_2016-12-14.mat')

### stimulus responses
resp = mt[‘stim’][0]['resp'][0]    # stimuli by neurons
istim = mt[‘stim’][0]['istim'][0]   # identities of stimuli in resp
spont = mt[‘stim’][0]['spont'][0]  # timepoints by neurons

### cell information
med = mt[‘med’]                 # cell centers (X Y Z)
mt[‘stat’][0]     # first cell’s stats
mt[‘stat’][0][‘npix’]       # one example field, tells you how pixels make up the cell

### loading images
mt = sio.loadmat('images_natimg2800_all.mat')
imgs = mt['imgs']  # 68 by 270 by number of images
# check out first image using matplotlib.pyplot
plt.imshow(imgs[:,:,0])

```
