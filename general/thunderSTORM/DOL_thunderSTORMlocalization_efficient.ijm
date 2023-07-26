// - find all tif files in root dir
// - concatenate them
// - create results array with name + path for all files
// - perform thunderSTORM localization on stack
// - export thunderSTORM result .csv
// - save results from array as .txt

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// define variables
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
root_dir = getDirectory("Choose a root directory containing subfolders");
save_dir = getDirectory("Choose a target directory for saving results");
identifier = "_mask.tif";					// identifier for excluding subset of .tif files. All other .tif files will be used for point extraction
pixelsize = 104;						// [nm]
par_threshold = newArray("2.3","2.4","2.5"); 			//threshold= par_threshold*std(Wave.F1). Default: 2.0
par_mf_enabled = newArray("false","true");			// multi emitter fitting.
par_mf_nmax = newArray("3");					// default: nmax=3
par_mf_sameint = newArray("false");				// default: keep_same_intensity=false
par_mf_pval = newArray("1.0E-6");				// default: pvalue=1.0E-6
par_mf_fixedint = newArray("false");				// default: fixed_intensity=false

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// processing script
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
setBatchMode(true)
fs = File.separator;
image_list = newArray();

// Obtain file list & create concatenated files
image_list = processFolder(root_dir,image_list);

// image_list export
for(o=0; o< lengthOf(image_list); o++) {
	setResult("image file", o, image_list[o]);
}
updateResults;
saveAs("Results", save_dir+"image_list.txt");

// thunderSTORM analysis on concatenated files
createstack(image_list);

run("Camera setup", "isemgain=true pixelsize="+pixelsize+" gainem=100.0 offset=94.5 photons2adu=5.12");
// loop across threshold values
for (l=0; l<par_threshold.length; l++){
	// loop across multi emitter fitting option
	for (m=0; m<par_mf_enabled.length; m++){
		// Save directory depends on parameter set
		if (par_mf_enabled[m] == "true") {
			savepath = ""+save_dir+"tsoutput_multiemitter"+"_thres_"+par_threshold[l]+".csv";
		}
		else if (par_mf_enabled[m] == "false") {
			savepath = ""+save_dir+"tsoutput_singleemitter"+"_thres_"+par_threshold[l]+".csv";
		}
		run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold="+par_threshold[l]+"*std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.5 method=[Maximum likelihood] full_image_fitting=false fitradius=3 fixed_intensity="+par_mf_fixedint[0]+" nmax="+par_mf_nmax[0]+" pvalue="+par_mf_pval[0]+" mfaenabled="+par_mf_enabled[m]+" keep_same_intensity="+par_mf_sameint[0]+" renderer=[No Renderer]");
		run("Export results", "filepath=["+savepath+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=true offset=true uncertainty=true y=true x=true");
	}
}

setBatchMode(false);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// functions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function processFolder(path,il) {
	filelist = getFileList(path);
	for (i=0; i<filelist.length; i++) {

		if (endsWith(filelist[i], "/")) {
			foldername = substring(filelist[i], 0, lengthOf(filelist[i])-1);
			folderpath = path + foldername + fs;
			//print("folder: " + folderpath);
		    il = processFolder(folderpath,il);
		}
		else {
			filename = filelist[i];
			filepath = path + filename;
			il = processFile(filepath,il);
		}
	}
	return il;
}

function processFile(path,il) {
	if (!(endsWith(path, identifier)) && endsWith(path,".tif")) {
		print(path);
		// construct file list
		il = Array.concat(il, path);
	}
	else {
	}
	return il;
}

function createstack(il){
	for (i=0; i<il.length; i++){
		path = il[i];
		open(path);
		rename("raw");
		// Check if loaded image is stack and perform averaging if so
		if (nSlices>1) {
			fsindex = lastIndexOf(path, "/");
			fpath = substring(path, fsindex, lengthOf(path));
			print("Warning: loaded image \""+fpath+"\" contains multiple frames. Performing averaging \n");
			print("Averaging is not implemented yet");
			rename("averaged");
			close("raw");
		}
		else {
			rename("averaged");
		}
		// Skip concatenating for first iteration of loop
		if (isOpen("procstack")) {
			run("Concatenate...", "  title="+"tmp"+"+ image1=procstack image2=averaged image3=[-- None --]");
			rename("procstack");
		}
		else {
			selectWindow("averaged");
			rename("procstack");
		}

	}
}
