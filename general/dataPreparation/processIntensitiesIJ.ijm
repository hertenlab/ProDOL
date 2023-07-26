/* Input: A Folder with folders with ALEX Tif movies and the 3Channels_Mask output folder 
 *  Output: A list of areas that result from the "_Mask.tif" 
 */

setBatchMode(true)



rowcount=0;

root_dir = getArgument(); //getDirectory("Choose a root directory containing further directories");

Endindex = lengthOf(root_dir);

inctime = substring(root_dir, lastIndexOf(root_dir,File.separator)+1, Endindex);



root_folder = File.getName(root_dir);

//find all directories
list = getFileList(root_dir); //These are the subfolders
for (i=0; i<list.length; i++) {
	if (endsWith(list[i], "/")) //only extract folder
	dir_list = Array.concat(dir_list, list[i]);
	
}

	
for (i=1; i<dir_list.length; i++) { //The first [0] entry of dir_list is a "0", therefore start with dir_list[1], this is also the condition name
	subdir_files = getFileList(""+root_dir+dir_list[i]+"3Channels_Mask/");

	showProgress(i-1, dir_list.length);
	

/*	for(j=0; j<subdir_files.length; j++) {
		print(subdir_files[j]);
	}
*/
	
	for(j=0; j<subdir_files.length; j++) {
		if (endsWith(subdir_files[j], "_mask.tif")) {

			name = subdir_files[j]; //This is the replicate name			
			dotIndex = indexOf(name, ".");
			image_title = substring(name, 0, dotIndex); //This is the replicate name without ".tif"

			
			imagepath=""+root_dir+dir_list[i]+"3Channels_Mask/"+name;
				
			open(imagepath);
			run("Properties...", "unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
			MaskImage=getImageID;


			setThreshold(100, 255);
			run("Create Selection");

			roiManager("add")
			

			LastDash = lastIndexOf(imagepath, "_");
			ImageStem=substring(imagepath, 0, LastDash);
			//print(ImageStem);
			
			redPath = ImageStem+"_red.tif";
			greenPath = ImageStem+"_green.tif";
			bluePath = ImageStem+"_blue.tif";
			
			if (File.exists(redPath)) {
				open(redPath);
				run("Properties...", "unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
				run("Subtract Background...", "rolling=20  create");
				roiManager("select", 0);					
				getStatistics(area, meanRed_temp);
			}
			else {
				meanRed_temp = 0;
			}

			if (File.exists(greenPath)) {
				open(greenPath);	
				run("Properties...", "unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
				run("Subtract Background...", "rolling=20  create");		
				roiManager("select", 0);
				getStatistics(area, meanGreen_temp);
			}
			else {
				meanGreen_temp = 0;
			}

			open(bluePath);
			run("Properties...", "unit=px pixel_width=1 pixel_height=1 voxel_depth=1");
			run("Subtract Background...", "rolling=20  create");		
			roiManager("select", 0);
			getStatistics(area, meanBlue_temp);

			meanBlue=round(meanBlue_temp);
			meanGreen=round(meanGreen_temp);
			meanRed=round(meanRed_temp);

			setResult("Area",rowcount,""+area);
			setResult("IntensityBlue",rowcount,""+meanBlue);
			setResult("IntensityGreen",rowcount,""+meanGreen);
			setResult("IntensityRed",rowcount,""+meanRed);
			setResult("condition",rowcount,""+dir_list[i]);
			setResult("replicate",rowcount,""+image_title);
			setResult("Image path",rowcount,""+imagepath);
			setResult("incubation time",rowcount,""+inctime);
			updateResults();
			roiManager("reset");
			rowcount=rowcount+1;


		while (nImages>0) { 
		          selectImage(nImages); 
		          close(); 
		      } 
			
			
		}
	}
	}

saveAs("Results", root_dir+"Intensities.txt");
    
     if (isOpen("Results")) {
         selectWindow("Results");
         run("Close");
    } 

