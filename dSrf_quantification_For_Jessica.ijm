//Quantification for Jess
//To use put maximum intensity projection images you wish to analyse into the same folder
//Use the setup section of the script at the beggining to setup parameters of the analysis.
//04/05/2018
//By Máté Nászai 

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//SETUP
//Select the channel you wish to quantify.
// Channel 0 = green
// Channel 1 = blue
// Channel 2 = red
// Channel 3 = farred
t1=2;
//Mask threshold modifier
mask_threshold_modifier=2.5; //This number was achieved by running all thresholding methods on ~30 images then averaging the threshold values without the Intermodes, Minimum and Shabang methods, Triangle thresholding method consistently followed trends in average threshold but was 2-3 fold lower for masking esg>GFP and DAPI

//TEST MODE
//boolean 0-off 1-on
test=0;
//END OF SETUP
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//SCRIPT
run("Close All");
run("Clear Results");

setBatchMode(true);
//Test mode switch
if (test){
setBatchMode(false);
}

//Get directory
dir=getDirectory("Choose Source");
list=getFileList(dir);

for (i=0; i<list.length; i++){

//Open file
run("Bio-Formats Importer", "open=" + dir + list[i] + " color_mode=Default rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT"); selectWindow(list[i] + " - C=" + t1); run("Duplicate...", "duplicate");

//Get threshold and number of slices
setAutoThreshold("Triangle dark stack"); getThreshold(lower,upper);

threshold=round(mask_threshold_modifier*lower);
//print(list[i] + " Threshold:" + threshold);

//Threshold image conventionally
setThreshold(threshold, 65535);
setOption("BlackBackground", true);
run("Convert to Mask", "method=Triangle background=Dark black"); rename("Mask"); run("Options...", "iterations=1 count=1 black do=Nothing"); run("Fill Holes", "stack"); run("Despeckle", "stack"); run("Despeckle", "stack"); run("Despeckle", "stack");

//Perform measurements
run("Set Measurements...", "  redirect=None decimal=3"); run("Analyze Particles...", "display"); print(list[i] + ": " + nResults);

//Test mode switch
if (!test){
run("Close All");
run("Clear Results");
}
}

setBatchMode(false);
