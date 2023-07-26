


setBatchMode(true)


root_dir = getArgument();//getDirectory("Choose a root directory containing further directories");

//root_dir = "Y:\\DOL Calibration\\Data\\felix\\raw\\2017-04-11_FB065_Calibration 60min\\";

root_folder = File.getName(root_dir);

//find all directories
list = getFileList(root_dir);
for (i=0; i<list.length; i++) {
	
	//print("Variable list"+list[i]);
	if (endsWith(list[i], "/"))  
	dir_list = Array.concat(dir_list, list[i]); //list of directories
}



for (i=1; i<dir_list.length; i++) {
showProgress(i-1, dir_list.length);

	if (!startsWith(dir_list[i],"Beads")) {
	subdir_files = getFileList(""+root_dir+dir_list[i]);
	
	CompFolder=root_dir+dir_list[i]+"3Channels_Mask/"; //Create Output folder
	
	File.makeDirectory(CompFolder);
	//print(root_dir+dir_list[i]+"3Channels_Mask/");
	
	
	
	for(j=0; j<subdir_files.length; j++) {
		if (endsWith(subdir_files[j], ".tif")) {

			name = subdir_files[j]; //full file name
			dotIndex = indexOf(name, ".");
			image_title = substring(name, 0, dotIndex); //file name without".tif"

			underscoreindex=lastIndexOf(name, "_");
			replicatename=substring(name, 0, underscoreindex+1);
			
			imagepath=""+root_dir+dir_list[i]+name;
			open(imagepath);
			parentImage=getImageID;

			//print(CompFolder+replicatename+"/mask/"+name);
			
			if (endsWith(name, "blue.tif")) {

			run("Z Project...", "stop=10 projection=[Average Intensity]");
			saveAs("tif", CompFolder+name);
			
			if (File.exists(CompFolder + replicatename + "/blue/")) {
				saveAs("tif", CompFolder+replicatename+"/blue/"+name);
			}

			//create mask based on GFP channel and save
			
				if (startsWith(name, "Beads")) {
				newImage("Untitled", "16-bit white", 512, 512, 1);	
				run("Convert to Mask");
				run("16-bit");
				name=replace(name,"blue","mask"); 
				saveAs("tif", CompFolder+name);
				
								
				} else {
				
				run("Subtract Background...", "rolling=20 light create");
				run("Bandpass Filter...", "filter_large=512 filter_small=25 suppress=None tolerance=5 autoscale saturate");
				run("Median...", "radius=30");
				setAutoThreshold("Triangle dark");
				setOption("BlackBackground", true);
				run("Convert to Mask");
				run("16-bit");
				name=replace(name,"blue","mask"); 
				saveAs("tif", CompFolder+name);
			
				if (File.exists(CompFolder + replicatename + "/mask/")) {
					saveAs("tif", CompFolder+replicatename+"/mask/"+name);
				}
				}
			}

			else if (endsWith(name, "green.tif")) {

			run("Z Project...", "stop=10 projection=[Average Intensity]");
			saveAs("tif", CompFolder+name);	
			
			if (File.exists(CompFolder + replicatename + "/green/")) {
				saveAs("tif", CompFolder+replicatename+"/green/"+name);
			}
			}

			else if (endsWith(name, "greenBleach.tif")) {

			run("Z Project...", "stop=10 projection=[Average Intensity]");

			name=replace(name,"greenBleach","bleached"); 
			saveAs("tif", CompFolder+name);
			
			if (File.exists(CompFolder + replicatename + "/bleached/")) {
				saveAs("tif", CompFolder+replicatename+"/bleached/"+name);
			}
			}

			else if (endsWith(name, "red.tif")) {
				if (matches(name, ".*gSEP.*")) {
				

					run("Z Project...", "stop=10 projection=[Average Intensity]");
					saveAs("tif", CompFolder+name);	
			
					if (File.exists(CompFolder + replicatename + "/red/")) {
						saveAs("tif", CompFolder+replicatename+"/red/"+name);
					}
				}	

				else if (matches(name, ".*LynG.*")) {
			
					run("Z Project...", "start=11 stop=20 projection=[Average Intensity]"); //Use frame 11 to 20 for LynG red only
					saveAs("tif", CompFolder+name);	
			
					if (File.exists(CompFolder + replicatename + "/red/")) {
						saveAs("tif", CompFolder+replicatename+"/red/"+name);
					}
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
			
			

//				print(root_dir);
//				print(dir_list[i]);
//				print(image_title);
//				print(root_dir+dir_list[i]+image_title+"_composite.tiff");




while (nImages>0) { 
          selectImage(nImages); 
          close(); 
      } 
			
			
		}
	}
	}
}

