// ============================================================
// Pipeline: ElmFluoLzCount – Automated Fluorescence Image Analysis
// Authors: Susana I. Sá, Sandra I. Marques / FMUP, FFUP
// Date: 2025-10
// Version: 7 (Channel workflow, Subarea and Z-stack analysis)
// ------------------------------------------------------------
// Description:
// This ImageJ/Fiji macro performs automated quantification of
// fluorescence microscopy images organized in a 4-level folder
// hierarchy [Group → Sample → Tissue → Field of view].
//
// The macro:
// - Loads single-channel fluorescence images (DAPI, Green, Red)
// - Prompts the user to select input/output directories
// - Checks folder structure consistency before processing
// - Allows the user to define custom identifiers for each channel
// - Identifies histological regions (Tissue level)
// - Supports separation and independent analysis of subregions
// - Allows manual ROI definition to exclude non-specific labeling
// - Performs background subtraction and contrast enhancement
// - Calculates optical density and integrated intensity per ROI
// - Uses StarDist (TensorFlow) for nuclear segmentation (DAPI)
// - Saves structured results for each Group and Sample
//
// Requirements:
// - Fiji/ImageJ version ≥ 1.54
// - Plugins: Bio-Formats, StarDist (TensorFlow backend)
// - Input format: fluorescence images (.tif), one file per channel
//
// Output:
// - Processed images and ROIs saved under /Results/[Group]/[Sample]/ folders
// - Results tables (.csv) with intensity and object counts per region
// - Segmentation masks and labeled images from StarDist
//
// Usage:
// 1. Open this macro in Fiji (Plugins → Macros → Edit).
// 2. Verify that the folder structure follows: Group/Sample/Tissue/Field.
// 3. Define the channel identifiers (e.g., c0 = DAPI, c1 = Green, c2 = Red).
// 4. Select input and output directories when prompted.
// 5. Draw ROIs to exclude artifacts or non-specific staining.
// 6. Run the macro (Plugins → Macros → Run…).
//
// Notes:
// - The tissue folder name must match the tissue sample identifier.
// - Ensure consistent folder naming: [Group]/[Sample]/[Tissue]/[Field]/.
// - Recommended for fluorescence quantification and morphometric analyses.
// - Fully compatible with StarDist (TensorFlow) and ROI Manager operations.
//
// ============================================================


waitForUser("Folder structure check", "IMPORTANT:\n\n" +
    "Before running this macro, make sure your input directory is correctly structured:\n\n" +
    "Group -> Sample -> Tissue -> Field\n\n" +
    "Example:\n" +
    "ElmFluoLzCount_Group1/\n" +
    " |-- Rat01/\n" +
    " |    |-- CA3/\n" +
    " |    |    |-- field1.tif\n" +
    " |    |    |-- field2.tif\n" +
    " |    |-- CA1/\n" +
    " |         |-- field1.tif\n" +
    " |-- Rat02/ ...\n\n" +
    "The macro will not work if the folder hierarchy is missing.\n" +
    "Please confirm this structure before selecting the input directory.\n"+
    "Press \"Cancel\" if folder structure is not set.\n"+
    "(For more information see https://github.com/up246512-ui/ElmFluoLzCount/blob/main/README.md)");


run("Set Measurements...", "area mean bounding shape integrated area_fraction display redirect=None decimal=3");

// ==================== PRINCIPAL DIR ===================================================
inputDir = getDirectory("choose the input directory");
Grupo = File.getNameWithoutExtension(inputDir);
results = "Results_" + Grupo;
outputDir = File.getParent(inputDir) + File.separator + results;
File.makeDirectory(outputDir);
folderRs = outputDir + File.separator + "Results";
File.makeDirectory(folderRs);

// To define the parameters to be used
dialogTitle = "Parameter Selection";
dapi = true;
green = true;
red = false;
DG = false;
stack = false;
AnArea = "";
items = newArray("DAPI", "Green", "Red");
dapi_id = "c0";
green_id = "c1";
red_id = "c2";
scale = 1;
micra = 100;
setscale = true;
subarea1 = ""
subarea2 = ""

Dialog.create(dialogTitle);
	Dialog.addMessage("Select all fluorescence channels to display:");
	Dialog.addCheckbox("DAPI (c0)", dapi);
	Dialog.addCheckbox("Green (c1)", green);
	Dialog.addCheckbox("Red (c2)", red);
	Dialog.addRadioButtonGroup("Channel for ROI selection", items, 1, 3, "DAPI");
	Dialog.addString("DAPI identifier (e.g., c0):", dapi_id);
	Dialog.addString("Green identifier (e.g., c1):", green_id);
	Dialog.addString("Red identifier (e.g., c2):", red_id);
	Dialog.addCheckbox("Z-stack images?", stack);
	Dialog.addMessage("Use the same name for the tissue sample and the third-level folder.");
	Dialog.addString("Tissue sample:", AnArea);
	Dialog.addCheckbox("Analyze two areas?", DG);
	Dialog.addString("Name subarea 1:", subarea1);
	Dialog.addString("Name subarea 2:", subarea2);
	Dialog.addCheckbox("Need to set scale?", setscale);
	Dialog.addNumber("Set image scale (pixels):", scale);
	Dialog.addNumber("Set known distance (µm):", micra);

	Dialog.show();

	dapi = Dialog.getCheckbox();
	green = Dialog.getCheckbox();
	red = Dialog.getCheckbox();
	channel = Dialog.getRadioButton();
	dapi_id = Dialog.getString();
	green_id = Dialog.getString();
	red_id = Dialog.getString();
	stack = Dialog.getCheckbox();
	AnArea = Dialog.getString();
	DG = Dialog.getCheckbox();
	subarea1 = Dialog.getString();
	subarea2 = Dialog.getString();
	setscale = Dialog.getCheckbox();
	scale = Dialog.getNumber();
	micra = Dialog.getNumber();

// ----------------------------------------------------------------------------------------
// Processing Folder sequence with data retrival from folder name
list = getFileList(inputDir);
print("Analyzing: " + Grupo);
processDir(inputDir, folderRs);

function processDir(inputDir, folderRs) {
	listdir = getFileList(inputDir);
	for (j = 0; j < listdir.length; j++) {
  		inputDir2 = inputDir + listdir[j];
  		if (!File.isDirectory(inputDir2)) {
  			continue; 
  			}
  		
        Rato = File.getNameWithoutExtension(inputDir2);
		print("Processing Sample: " + Rato);
		
		// Creat folder for Tissue sample
		folderRat = folderRs + File.separator + Rato;
        File.makeDirectory(folderRat);
        outputFolder = folderRat;
        
        processDir2(inputDir2, outputDir);  
 	    setBatchMode(false);
          }
}

// -------------------------------------------------------
// Processing Sample folder
function processDir2(inputDir2, outputFolder) {
	listdir2 = getFileList(inputDir2);
	found = false;
	
	for (k = 0; k < listdir2.length; k++) {
    	inputDir3 = inputDir2 + listdir2[k];
    	if (!File.isDirectory(inputDir3)) {
    		continue; 
    	}
    	
 	    BrAr=File.getNameWithoutExtension(inputDir3); 
		print("Tissue (region): " + BrAr);
		
   		if (BrAr == AnArea) {
   			found = true;
            processDir3(inputDir3, outputFolder);
        }
	}
	
	if (!found) {
		msg  = "No folder named \"" + AnArea + "\" was found under \"" + Grupo + "\".";
		showMessage("Macro Error", msg);
		exit(); 	
	}
}

// ---------------------------------------------------
// Processing Tissue (region) folder
function processDir3(inputDir3, outputFolder) { 
	listdir3 = getFileList(inputDir3);
	for (m = 0; m < listdir3.length; m++) {
   		inputFolder = inputDir3 + listdir3[m];
   		if (!File.isDirectory(inputFolder)) continue; 
   		
   		print("Processing Field/Stack: " + listdir3[m]);
		processFolder(inputFolder, outputFolder);
		} 
	}

// ------------------------------------------------------------
// Processing Field/Stack folder
function processFolder(inputFolder, outputFolder) { 
        list = getFileList(inputFolder);
        list = Array.sort(list);
	
	for (i = 0; i < list.length; i++) {
		function processFolder(inputFolder, outputFolder) {
			setBatchMode(true);					
			run("Show All");

// =================================================================================================
		// Image opening and z-ztack combination
			if (stack) {
				if (channel == "DAPI") {
					File.openSequence(inputFolder, " filter="+dapi_id+"  scale=50.0");
					filename = getInfo("image.title");		
					selectWindow(filename);
					run("Make Montage...", "columns=5 rows=6 scale=0.5 label");
					setBatchMode("show");
					run("Show All");
					waitForUser("Select the range of focused photos and click OK");
					run("Close All");
					}
					
				if (channel == "Green") {
					File.openSequence(inputFolder, " filter="+green_id+"  scale=50.0");
					filename = getInfo("image.title");		
					selectWindow(filename);
					run("Make Montage...", "columns=5 rows=6 scale=0.5 label");
					setBatchMode("show");
					run("Show All");
					waitForUser("Select the range of focused photos and click OK");
					run("Close All");
					}
					
				if (channel == "Red") { 	 
					File.openSequence(inputFolder, " filter="+red_id+"  scale=50.0");
					filename = getInfo("image.title");		
					selectWindow(filename);
					run("Make Montage...", "columns=5 rows=6 scale=0.5 label");
					setBatchMode("show");
					run("Show All");
					waitForUser("Select the range of focused photos and click OK");
					run("Close All");
					}
				
			// Slice Keeper to define the previously selected focused photos
				if (dapi) {
					File.openSequence(inputFolder, " filter="+dapi_id+"  scale=50.0");
				 	filenamed = getInfo("image.title");
					rename(filenamed + "_c0");
					Wind_c0 = getInfo("image.title");
					nameDapi_c0 = File.getNameWithoutExtension(Wind_c0);
					
					selectWindow(Wind_c0);
					run("Slice Keeper");
					run("Z Project...", "projection=[Sum Slices]");
					run("8-bit");
					
					path = Rato + "_"+ BrAr + "_" + nameDapi_c0;
					saveAs("Tiff", folderRat + File.separator + path + "_c0.tif");
					}
					
				if (green) {
					File.openSequence(inputFolder, " filter="+green_id+"  scale=50.0");
				 	filenamed = getInfo("image.title");
					rename(filenamed + "_c1");
			 		Wind_c1 = getInfo("image.title");
					nameGreen_c1 = File.getNameWithoutExtension(Wind_c1);
					
					setBatchMode("hide");
					selectWindow(Wind_c1);
					run("Slice Keeper");
					run("Z Project...", "projection=[Average Intensity]");
									run("8-bit");
					
					pathg = Rato + "_"+ BrAr + "_" + nameGreen_c1;
					saveAs("Tiff", folderRat + File.separator + pathg + "_c1.tif");
					}
					
				if (red) {			
					File.openSequence(inputFolder, " filter="+red_id+"  scale=50.0");
				 	filenamed = getInfo("image.title");
					rename(filenamed + "_c2");
			 		Wind_c2 = getInfo("image.title");
					nameRed_c2 = File.getNameWithoutExtension(Wind_c1);
					
					setBatchMode("hide");
					selectWindow(Wind_c2);
					run("Slice Keeper");
			 		run("Z Project...", "projection=[Average Intensity]");
					run("8-bit");	
					
					pathr = Rato + "_"+ BrAr + "_" + nameRed_c2;
					saveAs("Tiff", folderRat + File.separator + pathr + "_c2.tif");
					}
				close("*");	
				} 
		
	// ------------------------------------------------------------------------------------------------------
		// Image oppening without z-stack combination
			else{
				if (dapi) {                                                                                                                                                                                                                    
					setBatchMode(false);
					setBatchMode("show");
					File.openSequence(inputFolder, " filter="+dapi_id+"  scale=50.0");
					filenamed = getInfo("image.title");
					rename(filenamed + "_c0");
	 				Wind_c0 = getInfo("image.title");
					nameDapi_c0 = File.getNameWithoutExtension(Wind_c0);
					run("8-bit");
					
				// Scale calibrated according to the previous indication
					if (setscale) {
						run("Set Scale...", "distance="+scale+" known="+micra+" unit=um global"); 
						}
			
					path = Rato + "_"+ BrAr + "_" + nameDapi_c0;
					saveAs("Tiff", folderRat + File.separator + path + "_c0.tif");
					close("*");
					}
					
				if (green) {
					setBatchMode(false);
					setBatchMode("show");
					File.openSequence(inputFolder, " filter="+green_id+"  scale=50.0");
					filenameg = getInfo("image.title");
			 		rename(filenameg + "_c1");
			  		Wind_c1 = getInfo("image.title");
					nameGreen_c1 = File.getNameWithoutExtension(Wind_c1);
					run("8-bit");
					
				// Scale calibrated according to the previous indication
					if (setscale) {
						run("Set Scale...", "distance="+scale+" known="+micra+" unit=um global"); 
						}
						
					pathg = Rato + "_"+ BrAr + "_" + nameGreen_c1;
					saveAs("Tiff", folderRat + File.separator + pathg + "_c1.tif");
					close("*");
					}
					
				if (red) {
					setBatchMode(false);
					setBatchMode("show");
					File.openSequence(inputFolder, " filter="+red_id+"  scale=50.0");
			 		filenameA = getInfo("image.title");
			 		rename(filenameA + "_c2");
			 		Wind_c2 = getInfo("image.title");
			   		nameRed_c2 = File.getNameWithoutExtension(Wind_c2);
			   		run("8-bit");
					
				// Scale calibrated according to the previous indication
					if (setscale) {
						run("Set Scale...", "distance="+scale+" known="+micra+" unit=um global"); 
						}
					
					pathr = Rato + "_"+ BrAr + "_" + nameRed_c2;
					saveAs("Tiff", folderRat + File.separator + pathr + "_c2.tif");
					close("*");
					}
				close("*");	
				}
	
	// ========================================================================================================	
		// DAPI image processing	
			if (channel == "DAPI" && channel != "Green" && channel != "Red") {
				open(folderRat + File.separator + path + "_c0.tif");
				run("8-bit");
				
				run("Subtract Background...", "rolling=50 sliding stack");
				run("Enhance Contrast...", "saturated=0.01 normalize process_all");
				saveAs("Tiff", folderRat + File.separator + "ROI.tif");
				setBatchMode("show");
				
				setTool("polygon");
				waitForUser("Define ROI Area", "Use polygon tool to set ROI (Region of Interest):\n" + 
						"       Draw a ROI to exclude artifacts or non-specific regions from the analysis.");	
			
				ExtSelROI = getValue("selection.size");
				run("Measure");
			
				if (ExtSelROI > 0) {
					run("Clear Outside");
					roiManager("Add");
					roiManager("Select", 0);
					roiManager("Rename", "ROI");
					roiManager("Save", folderRat + File.separator + "ROI.roi");
					roiManager("reset");
					}  
				else {roiManager("reset");
					}
					
				if (roiManager("count") > 0) {
					roiManager("reset");
					}
			
				saveAs("Tiff", folderRat + File.separator + path + "_ROI_c0.tif");
				close("*");
				
				// -------------------------------------------------------------------------------------------
			// Processing tissue images with two different subareas
				if (DG) {
					open(folderRat + File.separator + path + "_ROI_c0.tif");
					setBatchMode("show");
					setBatchMode(false);
												
					setTool("polygon");
					waitForUser("Define " + subarea1 , "Use the polygon tool to define " + subarea1 + ". \n" +
								subarea2 +" will be determined as the inverse of " + subarea1 + ".");
					
					roiManager("Add");
					roiManager("Select", 0);
					roiManager("Rename", subarea1);
					roiManager("Save", folderRat + File.separator + subarea1 +".roi");
					run("Make Inverse");
					roiManager("Add");
					roiManager("Select", 1);
					roiManager("Rename", subarea2);
					roiManager("Save", folderRat + File.separator + subarea2 +".roi");
					roiManager("reset");
					
					roiManager("Open", folderRat + File.separator + subarea1 +".roi");
					roiManager("Select", 0);
					run("Measure");
					run("Clear Outside");
					saveAs("Tiff", folderRat + File.separator + "ROI_" + subarea1 +".tif");
					roiManager("reset");
					run("Select None");
					rename("ROI_SubArea1.tif");
					
					run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'ROI_SubArea1.tif', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.5', 'nmsThresh':'0.4', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
					selectImage("Label Image");
					selectImage("ROI_SubArea1.tif");
					roiManager("Show All");
		
					n = roiManager('count'); 
					for (i = 0; i < n; i++) {
	    				roiManager('select', i);
	        			roiManager("Measure"); 	
        				}
					roiManager("reset");
			
					saveAs("Results", folderRs + File.separator + path + "_" + subarea1 + "_results_DAPI.xls");
					close("Results");
					close("*");
			
					if (roiManager("count") > 0) {
						roiManager("reset");
						}
	 		
				// Processing SubArea 2
					setBatchMode("show");
					open(folderRat + File.separator + path + "_ROI_c0.tif");

					roiManager("Open", folderRat + File.separator + subarea2 +".roi");
					roiManager("Select", 0);
					run("Measure");
					run("Clear Outside");
					roiManager("reset");
		
					if (roiManager("count") > 0) {
						roiManager("reset");
						}
					saveAs("Tiff", folderRat + File.separator + "ROI_" + subarea2 +".tif");
					rename("ROI_SubArea2.tif");
					
					run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'ROI_SubArea2.tif', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.5', 'nmsThresh':'0.4', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
					selectImage("Label Image");
					selectImage("ROI_SubArea2.tif");
					roiManager("Show All");
		
					n = roiManager('count'); 
					for (i = 0; i < n; i++) {
	    				roiManager('select', i);
	    		   		roiManager("Measure");
    		   			}
					roiManager("reset");
	
					saveAs("Results", folderRs + File.separator + File.separator + path + "_" + subarea2 + "_results_DAPI.xls");
					close("Results");
					close("*");
						
					if (roiManager("count") > 0) {
						roiManager("reset");
						}
			
					} 
	 
	    // -------------------------------------------------------------------------------------------------
			// Processing single area tissue images             	    
				else {
			 		open(folderRat + File.separator + path + "_ROI_c0.tif");
			 		rename("ROI_c0.tif");
					setBatchMode("show");
			    	run("Show All");
				
					run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'ROI_c0.tif', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.5', 'nmsThresh':'0.4', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
					selectImage("Label Image");
					selectImage("ROI_c0.tif");
					roiManager("Show All");
			
					n = roiManager('count'); 
					for (i = 0; i < n; i++) {
			  	  		roiManager('select', i);
				 	 	roiManager("Measure");
			 	 		}
				
					saveAs("Results", folderRs + File.separator + path + "_" + "results_DAPI.xls");
					close("Results");
					close("*");
					roiManager("reset");
			 		}
					
				}
	
			print("DAPI images analyzed");
			
	// =======================================================================================
		// Processing Green photos
			if (channel == "Green" && channel != "DAPI" && channel != "Red") {
				setBatchMode("show");
				open(folderRat + File.separator + pathg + "_c1.tif");
				setTool("polygon");
				waitForUser("Define ROI Area", "Use polygon tool to set ROI (Region of Interest):\n" + 
						"       Draw a ROI to exclude artifacts or non-specific regions from the analysis.");	
			
				ExtSelROI = getValue("selection.size");
				run("Measure");
			
				if (ExtSelROI > 0) {
					run("Clear Outside");
					roiManager("Add");
					roiManager("Select", 0);
					roiManager("Rename", "ROI");
					roiManager("Save", folderRat + File.separator + "ROI.roi");
					roiManager("reset");
					}  
				else {roiManager("reset");
					}
					
					if (roiManager("count") > 0) {
						roiManager("reset");
						}
			
				saveAs("Tiff", folderRat + File.separator + pathg + "_ROI_c1.tif");
				close("*");
		
			// Processing tissue images with two different subareas
				if (DG) {
					open(folderRat + File.separator + pathg + "_ROI_c1.tif");
					setBatchMode("show");
					setBatchMode(false);
							
					setTool("polygon");
					waitForUser("Define " + subarea1 , "Use the polygon tool to define " + subarea1 + ". \n" +
								subarea2 +" will be determined as the inverse of " + subarea1 + ".");
						
					roiManager("Add");
					roiManager("Select", 0);
					roiManager("Rename", subarea1);
					roiManager("Save", folderRat + File.separator + subarea1 +".roi");
					run("Make Inverse");
					roiManager("Add");
					roiManager("Select", 1);
					roiManager("Rename", subarea2);
					roiManager("Save", folderRat + File.separator + subarea2 +".roi");
										
					if (roiManager("count") > 0) {
						roiManager("reset");
						}
	 				}
 				close("*");
			}
			
	// ==============================================================================================
		// Processing Red photos
			if (channel == "Red" && channel != "DAPI" && channel != "Green") {
				setBatchMode("show");
				open(folderRat + File.separator + pathr + "_c2.tif");
				setTool("polygon");
				waitForUser("Define ROI Area", "Use polygon tool to set ROI (Region of Interest):\n" + 
						"       Draw a ROI to exclude artifacts or non-specific regions from the analysis.");	
			
				ExtSelROI = getValue("selection.size");
				run("Measure");
			
				if (ExtSelROI > 0) {
					run("Clear Outside");
					roiManager("Add");
					roiManager("Select", 0);
					roiManager("Rename", "ROI");
					roiManager("Save", folderRat + File.separator + "ROI.roi");
					roiManager("reset");
					}  
				else {roiManager("reset");
					}
					
				if (roiManager("count") > 0) {
					roiManager("reset");
					}
			
				saveAs("Tiff", folderRat + File.separator + pathr + "_ROI_c2.tif");
				close("*");
							
			// Processing tissue images with two different subareas
				if (DG) {
					open(folderRat + File.separator + pathr + "_ROI_c2.tif");
					setBatchMode("show");
					setBatchMode(false);
							
					setTool("polygon");
					waitForUser("Define " + subarea1 , "Use the polygon tool to define " + subarea1 + ". \n" +
								subarea2 +" will be determined as the inverse of " + subarea1 + ".");
								
					roiManager("Add");
					roiManager("Select", 0);
					roiManager("Rename", subarea1);
					roiManager("Save", folderRat + File.separator + subarea1 +".roi");
					run("Make Inverse");
					roiManager("Add");
					roiManager("Select", 1);
					roiManager("Rename", subarea2);
					roiManager("Save", folderRat + File.separator + subarea2 +".roi");
										
					if (roiManager("count") > 0) {
						roiManager("reset");
						}
					close("*");
					}
				}
				
	// ==================================================================================================
		// Processing of channel batch photos
			if (dapi) {
				setBatchMode(false);
				run("Show All");
				open(folderRat + File.separator + path + "_c0.tif");
				}
				
			if (green) {
				setBatchMode(false);
			   	run("Show All");
			   	open(folderRat + File.separator + pathg + "_c1.tif");
				}
				 
			if (red) {
				setBatchMode(false);
			   	run("Show All");
			   	open(folderRat + File.separator + pathr + "_c2.tif");
				}
	
		// Scale calibrated according to the previous indication
			if (setscale) {
				run("Set Scale...", "distance="+scale+" known="+micra+" unit=um global"); 
				}
						
			setBatchMode(false);
			run("Show All"); 
			run("Images to Stack");
			saveAs("Tiff", folderRat + File.separator + path + "_stack.tif");
				
	// ------------------------------------------------------------------------------------
		// Confirm ROI placement
			if (ExtSelROI > 0) {
				roiManager("Open", folderRat + File.separator + "ROI.roi"); 
				roiManager("Select", 0);
				waitForUser("Check Selected ROI", "Confirm that the ROI is correct.\nIf not, create a new ROI.");
				run("Clear Outside");
				roiManager("reset");
				}
				
			else {
				waitForUser("Check Selected ROI", "Confirm that the ROI is correct.\nIf not, create a new ROI.");
				ExtSelROIR = getValue("selection.size"); 
						
				if (ExtSelROIR > 0) {
					run("Clear Outside");
					}
				roiManager("reset");
				}
	
		// Subarea analysis with subarea ROI
			if (DG) {
				setBatchMode(false);
				run("Show All");
				roiManager("Open", folderRat + File.separator + subarea1 +".roi");
				roiManager("Select", 0);
	 			run("Measure Stack...");
	 			roiManager("reset");
	 			roiManager("Open", folderRat + File.separator + subarea2 +".roi");
	 			roiManager("Select", 0);
	 			run("Measure Stack...");
	 			roiManager("reset");
				}  
				
			else {
				setBatchMode(false);
				run("Show All");
				run("Measure Stack..."); 
		   		}
	
			selectWindow("Results");
			newName = Rato + "_" + BrAr + "_" + nameDapi_c0 + "_" + "results_DO";
			saveAs("Results", folderRs + File.separator + newName + ".xls");
			close("Results");
			close("*");
			print(nameDapi_c0 + " Optic Density determined");
			}
		}
	}
print("That's all folks!");
