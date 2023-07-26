# object oriented dol analysis software

## classes

### pointset class
#### properties

+ `name` name to indicate source of points (e.g. 'u-track green', 'thunderStorm red', 'ground truth')
+ `(multichannelimage) parentImage` Image which this pointset belongs to
+ `sourceFile` original file where this pointset comes from (e.g. u-track point_sources/channel_x.mat or thunderStorm csv-file)
+ `pointDetectionParameters` information about the origin of this point set (e.g. u-track or thunderStorm point detection parameters)
+ `points` points belonging to this set (parameter order in `pointsColumns`)
+ `pointsColumns` parameters of `points` array ('x', 'y', 'x rotated', 'y rotated', 'x registered', 'y registered', 'amplitude', 'sigma', 'offset')
+ `pointDensity` density of points (in um^-2^ ) within `parentImage.segmentedArea ` derived from mask channel of parent multicolorimage
+ `transformation` transformation matrix to a reference channel derived from channel registration
+ `pointFilteringParameters` structure array to store parameters for point filtering. Field `origin` references the original set, filtering was applied on.  Additional fields are created from the parameter and values filtering is performed on.

### multichannelimage class

#### properties

+ `channels` color channels of multicolor image (e.g. blue, bleached, green, red, mask) with path of respective tif-file
+ `pixelSize` of tif files
+ `childPointSets` pointsets belonging to this image 
  That does not necessarily correspond to the channels, could be different point detection algorithms performed on one channel. Also filtering can create a new pointset containing less points
+ `parentImageSet`
+ `replicate` identifier to differ from other images in this imageset, usually the replicate
+ `segmentedArea` area derived from mask channel

### imageset class

+ `(multichannelimage) childImages`
+ `descriptors` variable number of unique parameters, defined as structure array with property-value pars. E.g. cell type, concentration, ... for cell screen; laser intensity, nd-filter for beads; dye combinations for dye screen; red/green background for simulated data. On overview table of the imagesets and descriptors of an object (array) can be called with `imgSet.getAllDescriptors()`
+ `(dolan) results` array to store colocalisation analysis data, like DOL, multi-assignments, density, etc.  averaged over all images of this imageset.
+ `colocThreshold` max distance for colocalisation

### dolan class

This is a universal class for storing results of any calculation within the DOL analysis. In most cases it refers to a quantity that relates from one (or more) pointset to another (or others), that can be stored as objects in basePointSet and targetPointSet (that is not mandatory, e.g. for a mean transformation matrix stored with an imageset it is just defined as string referring to the names of the pointsets). You can link objects as `includedPoints`, `includedImages` or `includedImageSets` whenever helpful. 

#### properties

* `basePointSet` reference pointset
* `targetPointSet` sample pointset
* `variable` name of the variable e.g. 'DOL' or 'transformation'
* `value` 
* `uncertainty`
* `comment` (e.g. to define uncertainty as std/var or value as mean/median)
* `includedPoints` points that were included for calculation of that 
* `includedPoints`
* `includedImages` (if all points of both channels are included)
* `includedImageSets` (if all multichannelimages are included)

# DOLAN routine

## Data import

As datasets are heterogeneous import of data has to be designed for every experiment individually. Generally it should follow the following order (if applicable):

1. construct imageset
   An imageset represents a collection of multichannelimages with identical conditions. These conditions are stored in `imgset.descriptors` and should contain at least enough descriptors to uniquely distinguish it from other imagesets you are working on in parrallel.
2. add images
   create a multichannelimage object for every replicate in every imageset. Add a channel name (usually: 'blue', 'green', 'red', 'mask', 'bleached', 'gray') and the path to the respective tif-file.
3. add pointsets by importing
   for every multichannelimage you can add any number of pointsets. Data formats and structures are different for sources of pointsets, so this has to be customized. Generally it is advisable to move through the DOLAN data structure (i.e. imagesets and multichannelimages) and to search for matches with the point sources.

## Visual Inspection for prescreening

dataSetInspector lets you browse through the dataset by displaying the 'blue' channel image and the segmentation. After visual inspection cells can be marked to be included or excluded for calculation of mean values in the set (e.g. DOL or density). The tool is called for a imageset with

```
dataSetInspector(imgset)
```

* You can use the keyboard to browse and classify. Keys are noted on the buttons.
* By ticking the checkbox 'random order' the 'next' and 'previous' buttons will browse to a (hidden) random order of the loaded samples.
* By ticking the checkbox 'unset only' images that have a classification are skipped. This will help if you resume an interrupted classification in random order
* If you encounter an error and the figure window cannot be closed focus the window and type `delete(gcf)` in the console

## Transformation (formerly known as registration)

Select a point set as a reference and align other pointsets to that reference. A full registration from all pointsets with name `targetName` to `baseName` can be performed by calling

```
imgset.fullTransformation('u-track blue', 'u-track green');
```

This calls the following methods consecutively:

```
imgset.calculateTransformation('u-track blue', 'u-track green');
```

- calculate transformation matrix for individual images
  - pointsets are filtered to contain only pairs with a single neighbor with a distance < 2px (This means that pointsets have to be prealigned)
  - transformation matrix is only calculated when >50 point pairs are available
  - transformation matrix is stored as pointset property `ptSet.transformation.T`
  - if calculated transformation uses large changes (translation > 20px, rotation > 5°, scaling > 1%) a warning is displayed

```
meanTgreen = imgset.calculateMeanTransformation('u-track blue', 'u-track green');
```

- calculate mean transformation (on imageset or imageset vector)

```
imgset.applyTransformation('u-track blue', 'u-track green');
```

- perform registration for all points
- pointsets with name 'u-track blue' are set as reference. Their transformation matrix is set to unity and registeres positions of points are copied from original positions.

## Point filtering

### Filter by fixed value of point parameter

You can filter points by their properties 'sigma', 'amplitude' and 'background' using the pointset method filterpoints

```
ptSet.filterPoints(newName, pointParameter, filterValues, appendOrReplace)
```

It will create a new pointset with the name `newName` and copy the points matching the `filterValues` of `pointParameter`. This new pointset will be attached to the parent multichannelimage, you can toggle between appending the new pointset or replacing an existing pointset with identical name.

`filterValues` is a 2-element vector. If the second element is greater than (or equal to) the first, it means only points are accepted, that lie within these values. Otherwise points are accepted with values greater than the first or smaller than the second. 

Example 1:

```
ptSet.filterPoints('filtered', 'sigma', [0.7 2.7], 'replace');
```

will accept points with `0.7 < sigma < 2.7`, create a new pointset with the name 'filtered' and replace a pointset of the parent multichannelimage with the same name .

Example 2:

```
ptSet.filterPoints('filtered', 'aplitude', [1000 500], 'append');
```

will accept points with `amplitude > 1000` or `amplitude < 500` and append the new pointset to the parent multicolorimage

To perform filtering on all pointsets (with a certain name) on all multichannelimage of an imageset you can call the imageset method filterPointsByValue.

```
img.set.filterPointsByValue(targetName, newName, pointParameter, filterValues, appendOrReplace)
```

`targetName` is the name of the pointset to be filtered.

### Filter by percentage of reference imageset

The imageset method filterPointsByPercentile will determine the `filterValues` for `pointset.filterPoints()` by calculating the percentile of the point parameter for all points of a reference set. This could be an unstained cell.

```
imgset.filterPointsByPercentile(baseSet, targetName, newName, pointParameter, percentile, appendOrReplace)
```

will determine the `percentile` of `pointParameter` of all points in `baseSet` and filter all points in `imgset` to be higher than this threshold.

## DOL calculation

* call method colocalisation on imageset or multicolorimage with base and target pointset name. DOL is always calculated "in both ways" i.e. with respect to number of points of base and target pointset and added as result to both pointsets

```
imgset.colocalisation('u-track blue', 'u-track red');
```

That consecutively performs the following steps:

```
imgset.calculateColocOverThresholds('u-track blue', 'u-track red');
```

* Calculate the degree of colocalisation between two pointsets over a distance threshold from 0.1 to 4 pixels with a step size of 0.1 px. Additionally multiple assigned points are stored and both (DOL and multi-assignments) are performed for one pointset rotated (Random). Results are stored as dolan objects with the respective multichannelimage. (varNames: 'DOL over threshold',  'multi-assignments over threshold', 'DOL-Random over threshold', 'multi-assignments-Random over threshold')

```
obj.findSignificantThreshold('u-track blue', 'u-track red');
```

* Find significant colocalisation distance threshold by comparing the degree of colocalisation with random control in dependence of the distance threshold. The significant threshold is stored with the imageset. Only pointsets with succesful registration are included assuming these are samples with a significant number of actually colocalizing points.

```
obj.setSignificantDOL('u-track blue', 'u-track red');
```

* Use the significant distance threshold and determine the DOL for every multichannelimage. Results are stored as dolan objects with the multichannelimage (varNames:  'DOL',  'multi-assignments', 'DOL-Random', 'multi-assignments-Random')

```
obj.calculateMeanColocalisation('u-track blue', 'u-track red');
```

* Calculate average DOL (and other quantities) over all images of an imageset at the significant distance threshold. Results are stored with the imageset as dolan objects (varNames: 'mean DOL', 'mean DOL Random', 'mean multi-assignments', 'mean multi-assignments Random')

## Calculate Average Densities in imageset

To be documented...

## Density correction

The DOL can be corrected by the found density of points to compensate missed localisation due to psf-overlapping. The imageset method `imgset.densityCorrection(baseName, targetName, offset, slope)` will correct the DOL for all images in the included imageset(s). Input parameters are the name of base and target pointset for whom the DOL will be corrected and offest and slope of the linear fit of the density correction derived from simulated data.

## Access DOL data

* For a single image: E.g. retrieve DOL from 'u-track green' to 'u-track blue'

```
mci.results.dolanByVars('basePointSet', mci.pointSetByName('u-track blue'), ...
	'targetPointSet', mci.pointSetByName('u-track green'),...
	'varName', 'DOL');
```

Same thing works for multiple assigned points as well as DOL and multi-assignments for rotated image with their respective `varName`

* For one or more imagesets group dolans first, then use dolanByVars to extract the ones of interest. E.g. to plot the mean DOL with errorbars against the effective laser intensity for beads you can use:

```
allResults = [beadsImageSets.results];
dolDolans = allResults.dolanByVars('varName', 'mean DOL',...
    'basePointSet', 'u-track blue',...
    'targetPointSet', 'u-track green');

% plot dol vs. effective laser intensity
for i = 1:length(dolDolans)
    Ieff(i) = dolDolans(i).includedImageSets.descriptors.effectiveIntensity;
    dol(i) = dolDolans(i).value;
    dol_std(i) = dolDolans(i).uncertainty;
end

errorbar(Ieff, dol, dol_std);
xlabel('effective intensity')
ylabel('DOL')
```

# Image Display

The method `showImage` displays a multicolorimage and overlays pointsets. Indicate a cell array to display the image channels (as defined in imageset creation, e.g. 'red', 'green', 'blue', 'gray', 'mask') if available and a string or a cell array for pointsets to be displayed.

Example:

```
showImage(myImage, {'red', 'blue', 'mask'}, {'u-track red', 'u-track blue'})
```

displays the red and blue image channel, the outline from the segmentation mask and overlays points from pointset 'u-track red' and 'u-track blue'.

