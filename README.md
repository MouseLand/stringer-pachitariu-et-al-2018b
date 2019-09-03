# stringer-pachitariu-et-al-2018b
Code to analyze recordings of 10,000 neurons in response to 2,800 natural images presented twice

This code produces the figures from Stringer, Pachitariu et al, 2018b:

Carsen Stringer, Marius Pachitariu, Nicholas Steinmetz, Matteo Carandini, Kenneth D. Harris. *High-dimensional geometry of population responses in visual cortex.* bioRxiv. ([link](https://www.biorxiv.org/content/early/2018/07/22/374090))

It relies on data deposited on figshare at:

Carsen Stringer, Marius Pachitariu, Nicholas Steinmetz, Matteo Carandini, Kenneth D. Harris. *Recordings of ten thousand neurons in visual cortex in response to 2,800 natural images.* ([link](https://figshare.com/articles/Recordings_of_ten_thousand_neurons_in_visual_cortex_in_response_to_2_800_natural_images/6845348))

The datasets to produce all the main figures are available. The script 'process_data.m' is the main processing script. Set useGPU=0 if you do not have a GPU. The calls to the figure functions live in 'make_figs.m'.


# Data description 

If you use the data please cite the original paper and the figshare DOI.

### Stimulus conditions  

Each visual stimulus is presented across 3 screens surrounding the mice. Each of the following stimulus sets was presented at least twice in a recording: 
- natimg2800: 2800 different natural images 
- natimg2800_white: same 2800 natural images were whitened with a degree of 1 
- natimg2800_8D: same 2800 natural images, but projected onto the top 8 dimensions of reverse correlation between the stimuli and the responses (see the paper for more details) 
- natimg2800_4D: same 2800 natural images, but projected onto the top 4 dimensions of reverse correlation between the stimuli and the responses (see the paper for more details) 
- natimg2800_small: same 2800 natural images, but the image is only non-zero at the receptive field location of the cells 

Each of the following stimulus sets was presented 96 times in a recording: 
- ori32: 32 different directions of drifting gratings 
- natimg32: 32 different full-field natural images 

### Summary of recordings

**dbstims.mat**: Database of recording information. In summary there are 32 total recordings: 7 natimg2800, 4 natimg2800_white, 6 natimg2800_8D, 4 natimg2800_4D, 3 natimg2800_small, 4 ori, 4 natimg32 
- *dbstims*: database with information about recording sessions in order specified above (mouse_name and date are used to identify each recording)
- *stimset*: names of each of the different recording types 
- *stype*: for each k in stype, dbstims(k) is recorded with stimulus condition stimset{stype(k)} 

### Responses

**stimset_mname_date.mat**

Each file is a different session with images given by "stimset" with mouse_name "mname" and date "date" 
- *db*: database file of information about recording 
- *stat*: single cell statistics of cell detection algorithm (Suite2p). 
- *stat.redcell*: (for some recordings) indicated whether the cell had tdtomato and was therefore an interneuron (GAD+).  
- *stat.redprob*: (for some recordings) contains the classifier’s probability that a cell has tdtomato (from 0 to 1).  
- *med*: estimated 3D position of cells in tissue.  
- *stim.resp*: average stimulus response of each neuron (stim presentations x neurons), these are averaged over 2 time bins, and are aligned to the onset of the plane in which each neuron lives. These are in the order in which the stimuli were presented. 
- *stim.istim*: stimulus identity of each stim.resp (biggest stimulus e.g. 2801 indicates gray screen shown instead of image) 
- *stim.spont*: spontaneous activity during recording, averaged over 2 time bins, includes gray screen presentations during stimulus blocks 
- (if orientation recording, *stim.ori* indicates direction of drifting grating) 

### Image files 

All image files contain a matrix imgs which is 68 degrees by 270 degrees by number of images, where degrees represent degrees of the mouse's visual space. 
- **images_natimg2800_all.mat**: The same natural images were shown to all mice.
- **images_natimg2800_white_all.mat**: The same whitened natural images were shown to all mice.
- **images_natimg2800_8D_mname_date.mat**: Images presented during recording natimg2800_8D_mname_date.mat 
- **images_natimg2800_4D_mname_date.mat**: Images presented during recording natimg2800_4D_mname_date.mat 
- **images_natimg2800_small_mname_date.mat**: Images presented during recording natimg2800_small_mname_date.mat 

Extra: **sparseStats.mat** are the powerlaws from sparse noise recordings; **allimgs.mat** contains example images from the images*.mat 


### How to load the data into python

See also notebook [powerlaws.ipynb](python/powerlaws.ipynb).

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

### Class assignment
The stimuli in the present study is composed of natural images from several several natural categories; their class assignment was not used at all in the analysis.

However, manually labeled class assignment is avaialable in the `classes` folder:
* `claeeses/stimuli_class_assignment.mat` contains categorization of the stimuli into 15 classes ('birds', 'cats', 'flowers', 'hamsters', 'holes', 'insects', 'mice', 'mushrooms', 'nests', 'pellets', 'snakes', 'wildcats', 'other animals', 'other natural', 'other man made') and an additional 'unknown' class.
* `claeeses/stimuli_class_assignment_confident.mat` contains categorization of the stimuli into 11 classes ('birds', 'cats', 'flowers', 'hamsters', 'holes', 'insects', 'mice', 'mushrooms', 'nests', 'pellets', 'snakes') where the  'wildcats' class was merged into 'cats' and 'other animals', 'other natural', 'other man made' are considered 'unknown'.

Both `mat` files contains:
* a `class_assignment` variable which is a vector of length 2800 with the corresponding class id;
* a `class_names` variable with the corresponding class names (zero-based, so that the first entry is 'unknown' which correspond to id=0, the second is 'birds' and correspond to id=1, etc.).

A matlab GUI application used to perform the classification is also provided in `classes/class_verify`. It is provided here just for referrence and is not further documented.
