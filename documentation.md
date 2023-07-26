# Functions

### colocalisationThreshold

Calculate distance threshold for colocalisation analysis from number of
colocalising particles over a threshold range and number of random
colocalisation (from rotated coordinations).

### detectColocalisation

Function to calculate colocalisation of particles. Originally created by
Sigi.\
Modified by Felix on 18.12.2018:

-   Colocalisation determined from euclidean distance in x and y
    (instead of Δx AND Δy being smaller than the threshold)

-   Total number of colocalizing particles (totalColoc) is corrected for
    multiple assigments. The net colocalization (netColoc) is calculated
    from colocalizing particles in one channel reduced by the overhead
    of multi-assignments in the other channel.\
    i.e. if Channel 1 has 30 colocalizing particles of which 5 are
    double assigned and Channel2 has 20 colocalizing particles of which
    15 are double assigned, the net colocalization is 30 - (15 - 5)
    = 20. Note that if the number of colocalizing particles in the other
    channel is lower, the number is not reduced by the (negative)
    difference, i.e. for switching Channel1 and Channel2 the net
    Colocalisation is 20 - 0 = 20.

### meanAndStd

-   function that calculates and outputs mean and std values of multiple
    input variables calculated separetaly on subgroups of the input data

-   use this in combination with findgroups command

-   example: calculate the mean DOL in screen experiments on groups of
    identical cell type, incubation time and concentration (= mean over
    replicates)\
    % Calculate mean values

> \[groups, concID, CellTypeID, timeID\] = findgroups(concentration,
> CellType, incubation_time);
>
> OutputStruct = meanAndStd(valid, groups, DOL_BlueC);

-   output is stored in structure array with field names of input
    variables and "Mean\_" / "Std\_" prefix\
    OutputStruct =

> struct with fields:
>
> Mean_DOL_Blue: \[80×1 double\]
>
> Std_DOL_Blue: \[80×1 double\]

### dispProgress

function that displays progress inside one or more for-loops. Call with
current looping variable(s) and maximum value(s)

## dataPreparation

### dataPreparation

Wrapper script to prepare Imaging data for point detection. Calls the
other functions and performs data preprocessing, averaging and
segmentation and organizes the resulting files.

### move3ChannelFolders

Moves folders with averaged images and cell masks to a new folder.

### processAverageIJ

ImangeJ script that averages the movies over 10 frames and creates cell
mask from blue channel.

### processIntensitiesIJ

ImageJ script that calculates a rolling ball background in the cells and
measures the size of the segmented cell mask (in px)

### processMMData

Renames tif-files created with Micromanager scripts

## pointFiltering

### filterPointsByPercentile

Filter points by a threshold value intrinsically calculated from a
subset of the data. Use this for calculating an amplitude threshold from
unstained cells.

### filterPointsByThreshold

Filter points by a fixed threshold value.

## Registration

### applyTranslation

Applies translation to x- and y-coordinates

### channelRegistration

Function to register two channels by two sets of coordinates. Unreg is
mapped to Ref. The function checks if more than 10 points are present in
both channel and then calls **SigiRegistrationCells**

### correlatedRegistration

Complements registration. If Registration was succesful in only one
channel, the translation of the other one is correlated. Must run before
**meanTranslation**

### meanTranslation

Complements registration. If registration was not succesful in any
channel, the translation is calculated by the mean value of succesful
registrations. Must run after **correlatedTranslation**

### NearestNeighborDistance

This function calculates the distance between nearest neighbours in X
and Y direction

### SigiRegistrationCells

Mapping of one set of coordinates two another. Tries to find global
translation values in x and y to minimize the nearest neighbor distance.
Calls function **NearestNeighborDistance**

## u-track

### software

-   u-track package for tracking

### pointsFromMovieData

-   extract point coordinates and gauss fit parameters from movieData
    file

# Scripts

Scripts are specified for a certain experiment type (e.g. screen,
simulations, etc). They call the general functions in a certain order
and with specific parameters depending on the underlying experimental
aim and data structure. They should be stored in an own folder and named
with a appropriate prefix.

## cherrPick

-   GUI

-   select cells to be neglected from downstreamAnalysis by showing
    images in reference channel and created masks

## pointExtraction

-   read point positions from point detection (e.g. u-track movieList
    file)

-   Create identifiers to uniquely discern single cells (e.g. replicate,
    concentration,...)

-   Read additional parameters (e.g. cell area from mask or IJ
    Intensities.txt file)

## cellAnalysis

-   filter points

-   rotate points

-   calculate colocalisation

## showPoints

-   show images and overlay with points from point detection

-   GUI allows variation of contrast, display of individual channels and
    points

## downstreamAnalysis

-   Calculate particle densities

-   Calculate distance threshold for colocalisation (finalThreshold)

-   Calculate mean values over groups of cells with same conditions
    (e.g. all identifiers except replicate) using function meanAndStd.m

## plots

-   create plots for the aspects of interes

## pipeline

-   call combination of scripts successively

# thunderSTORM point detection

### DOL_thunderSTORMlocalization_efficient.ijm

Script to call thunderSTORM engine on directory containing .tif files.
Recursively processes subdirectories. Script requires user input to
specify point detection parameters and source/target directories.

# thunderSTORM point detection datasets Matlab integration

## Classes

### movie

Object containing variable number of analysis objects.

**Properties**

-   incubation time

-   cell-type

-   concentration

-   replicate

-   analysis objects (see below)

### analysis

Object containign pointsets from specific thunderSTORM point detection
run.

**Properties**

-   id: point id in thunderSTORM output file

-   frame: corresponds to line in image_list.txt file

-   point properties: x,y, sigma,
    intensity(=amplitude),offset,bkgstd,uncertainty

-   fittype: single or multi emitter fitting

-   threshold: for candidate filtering before sub-pixel localization

-   channel (can be „blue", „green", „red")

## Functions

### importTSeff

Requires link to image_list.txt file and directory containing output
files from ***DOL_thunderSTORMlocalization_efficient.ijm***. Will create
one movie object per imageset with a variable number of analysis childs
depending on contents of image_list.txt and output directory. Uses
***conditionsFromPathTS.m*** to fill properties of analysis and movie
objects. Uses ***pointsFromTS.m*** to extract point data from
thunderSTORM output .csv files.

### importTS

Function to create movie object array from thunderSTORMlocalization.ijm
analysis. Outdated, kept for compatibility with old thunderSTORM pd
results.

### convertTStoDOL

Generates cell arrays required for old DOL analysis from thunderSTORM
movie/analysis objects. Outdated.
