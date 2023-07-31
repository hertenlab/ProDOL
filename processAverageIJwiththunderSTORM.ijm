//Code by F Hild, J Euchner, K Yserentant & SA Tashev//
//University of Birmingham - 2023

/*
 - find all tif files in root dir
 - concatenate them
 - create results array with name + path for all files
 - perform thunderSTORM localization on stack
 - export thunderSTORM result .csv
 - save results from array as .txt
*/


reference = "eGFP"
HaloTag = "HaloTag"
SNAPtag = "SNAPtag"
pixelsize = 105.6;						// [nm]
gain= 200;
offset=209;
ADUphoton=4.1;

Dialog.create("Analysis parameter wizard");
	Dialog.addMessage("ProDOL data preparation");
	Dialog.addString("Reference Identifier", reference);
	Dialog.addString("HaloTag Identifier", HaloTag);
	Dialog.addString("SNAPtag Identifier", SNAPtag);
	Dialog.addString("Pixelwidth [nm]", pixelsize);
	Dialog.addString("Camera gain", gain);
	Dialog.addString("Camera offset", offset);
	Dialog.addString("ADU of photons", ADUphoton);
	Dialog.show();
	
root_dir = getDirectory("Choose a root directory containing image data");
root_folder = File.getName(root_dir);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// define variables
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
save_dir = root_dir;
identifier = "_mask.tif";					// identifier for excluding subset of .tif files. All other .tif files will be used for point extraction

par_threshold = newArray("2.0"); 			//threshold= par_threshold*std(Wave.F1). Default: 2.0
par_mf_enabled = newArray("true");			// multi emitter fitting.
par_mf_nmax = newArray("3");					// default: nmax=3
par_mf_sameint = newArray("false");				// default: keep_same_intensity=false
par_mf_pval = newArray("1.0E-6");				// default: pvalue=1.0E-6
par_mf_fixedint = newArray("false");				// default: fixed_intensity=false

setBatchMode(true);

//find all directories
list = getFileList(root_dir);

for (i=0; i<list.length; i++) {
	//print("Variable list"+list[i]);
	if (endsWith(list[i], "/"))  
		dir_list = Array.concat(dir_list, list[i]); //list of directories
}

for (i=1; i<dir_list.length; i++) {
	cellID=0;
	showProgress(i-1, dir_list.length);
	
		if (!startsWith(dir_list[i],"Beads")) {
		subdir_files = getFileList(""+root_dir+dir_list[i]);
		CompFolder=root_dir+dir_list[i]+"3Channels_Mask/"; //Create Output folder
		
		File.makeDirectory(CompFolder);
		
		for(j=0; j<subdir_files.length; j++) {
			if (matches(subdir_files[j], ".*"+reference+".*")) {
				nameref = subdir_files[j]; //full file name
				nameStem=replace(nameref,reference,"");
				dotIndex = indexOf(nameStem, ".");
				image_base = substring(nameStem, 0, dotIndex); //file name without".tif"
				cellID=cellID+1;
				for(k=0; k<subdir_files.length; k++) {
					cellNo=leftPad(cellID, 2);
					if (matches(subdir_files[k], ".*"+image_base+".*") && endsWith(subdir_files[k], ".tif")) {
						name = subdir_files[k]; //full file name
						imagepath=""+root_dir+dir_list[i]+name;
						open(imagepath);
						parentImage=getImageID;
						
						if (matches(name, ".*"+reference+".*")) {
							run("Z Project...", "stop=10 projection=[Average Intensity]");
							saveAs("tif", CompFolder+"cell"+cellNo+"_eGFP.tif");
							
						//create mask based on GFP channel and save
							if (startsWith(name, "Beads")) {
								newImage("Untitled", "16-bit white", 512, 512, 1);	
								run("Convert to Mask");
								run("16-bit");
								name=replace(name,reference,"mask"); 
								saveAs("tif", CompFolder+"cell"+cellNo+"_mask.tif");
							} else {
								run("Subtract Background...", "rolling=20 light create");
								run("Bandpass Filter...", "filter_large=512 filter_small=25 suppress=None tolerance=5 autoscale saturate");
								run("Median...", "radius=30");
								setAutoThreshold("Triangle dark");
								setOption("BlackBackground", true);
								run("Convert to Mask");
								run("16-bit");
								name=replace(name,reference,"mask"); 
								saveAs("tif", CompFolder+"cell"+cellNo+"_mask.tif");
							}
						}
			
					else if (matches(name,".*"+HaloTag+".*")) {
						run("Z Project...", "stop=10 projection=[Average Intensity]");
						saveAs("tif", CompFolder+"cell"+cellNo+"_Halo.tif");	
					}
			
					else if (endsWith(name, "greenBleach.tif")) {
						run("Z Project...", "stop=10 projection=[Average Intensity]");
						name=replace(name,"greenBleach","bleached"); 
						saveAs("tif", CompFolder+"cell"+cellNo+"_bleached.tif");
					}
			
					else if (matches(name, ".*"+SNAPtag+".*")) {
							if (matches(name, ".*gSEP.*")) {
								run("Z Project...", "stop=10 projection=[Average Intensity]");
								saveAs("tif", CompFolder+"cell"+cellNo+"_SNAP.tif");	
							}	
			
						else if (matches(name, ".*LynG.*")) {
								run("Z Project...", "start=11 stop=20 projection=[Average Intensity]"); //Use frame 11 to 20 for LynG red only
								saveAs("tif", CompFolder+"cell"+cellNo+"_SNAP.tif");	
							}
							else {
								run("Z Project...", "stop=5 projection=[Average Intensity]");
								saveAs("tif", CompFolder+"cell"+cellNo+"_SNAP.tif");
							}
						}
						else {
							print(""+root_dir+dir_list[i]+name+" has a wrong file name");
							newname=getString("please correct the filename", name);
							File.rename(root_dir+dir_list[i]+name, root_dir+dir_list[i]+newname);
							subdir_files[j]=newname; //Correct the filename and go back in the loop 
							j=j-1;
							//error(""+root_dir+dir_list[i]+name+" has a wrong file name");
						}
			
						while (nImages>0) { 
						          selectImage(nImages); 
						          close(); 
			  			} 
					}
				}
			}
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// processing script
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
fs = File.separator;
setBatchMode(true);
rootfilelist = getFileList(root_dir);
for (i=0; i<rootfilelist.length; i++) {
	run("Clear Results");
	image_list = newArray();
	if (endsWith(rootfilelist[i], "/")) {
		foldername = substring(rootfilelist[i], 0, lengthOf(rootfilelist[i])-1);
		folderpath = root_dir + foldername + fs;
		image_list = processFolder(folderpath,image_list);
		// image_list export
		for(o=0; o< lengthOf(image_list); o++) {
			setResult("image file", o, image_list[o]);
		}
		updateResults;
		File.makeDirectory(save_dir+""+foldername+"/ThunderSTORM_results");
		saveAs("Results", save_dir+""+foldername+"/ThunderSTORM_results/image_list.txt");
		
		// thunderSTORM analysis on concatenated files
		run("Close All");
		createstack(image_list);
		
		run("Camera setup", "isemgain=true pixelsize="+pixelsize+" gainem="+gain+" offset="+offset+" photons2adu="+ADUphoton+"");
		// loop across threshold values
		
		for (l=0; l<par_threshold.length; l++){
			// loop across multi emitter fitting option
			for (m=0; m<par_mf_enabled.length; m++){
				// Save directory depends on parameter set
				if (par_mf_enabled[m] == "true") {
					savepath = ""+save_dir+""+foldername+"/ThunderSTORM_results/tsoutput_multiemitter"+"_thres_"+par_threshold[l]+".csv";
				}
				else if (par_mf_enabled[m] == "false") {
					savepath = ""+save_dir+""+foldername+"/ThunderSTORM_results/tsoutput_singleemitter"+"_thres_"+par_threshold[l]+".csv";
				}
				run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold="+par_threshold[l]+"*std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.5 method=[Maximum likelihood] full_image_fitting=false fitradius=3 fixed_intensity="+par_mf_fixedint[0]+" nmax="+par_mf_nmax[0]+" pvalue="+par_mf_pval[0]+" mfaenabled="+par_mf_enabled[m]+" keep_same_intensity="+par_mf_sameint[0]+" renderer=[No Renderer]");
				run("Export results", "filepath=["+savepath+"] fileformat=[CSV (comma separated)] id=true frame=true sigma=true bkgstd=true intensity=true saveprotocol=true offset=true uncertainty=true y=true x=true");
			}
		}	
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
	if (!(endsWith(path, identifier)) && endsWith(path,".tif") && matches(path,".*3Channels_Mask.*")) {
		// construct file list
		il = Array.concat(il, path);
	}
	else {
	}
	return il;
}

function leftPad(n, width) {
	s =""+n;
	while (lengthOf(s)<width)
	s = "0"+s;
	return s;
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
run("Close All");
Dialog.create("Analysis done");
	Dialog.addMessage("ProDOL data preparation completed");
	Dialog.show();
