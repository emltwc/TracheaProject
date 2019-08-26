//Dsrf and pH3 colocalisation for Jessica

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//SETUP

//dSRF channel
t1=2;
mask_threshold_modifier_t1=5;
//pH3 channel
t2=3;
mask_threshold_modifier_t2=5;

//TEST MODE
test=1;
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
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Start:",year, month+1 ,dayOfMonth, hour, minute, second);
for (i=0; i<list.length; i++){
	run("Bio-Formats Importer", "open=" + dir + list[i] + " color_mode=Default rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT stitch_tiles");

	selectWindow(list[i] + " - C=" + t1);
	run("Duplicate...", "duplicate");
	rename("Channel t1");
	
	//Pre-process t1
	run("Despeckle", "stack");
	run("Subtract Background...", "rolling=50");
	run("Despeckle", "stack");
	run("Despeckle", "stack");
	//Get threshold
	if (nSlices>1){
	setSlice(floor(nSlices/2));
	}
	setAutoThreshold("Triangle dark stack");
	getThreshold(lower,upper);
	threshold=round(mask_threshold_modifier_t1*lower);
	print("Threshold t1:",list[i], threshold);
	//Threshold t1
	setThreshold(threshold, 65535);
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Triangle background=Dark black");
	rename("T1_Mask");
	run("Fill Holes", "stack");

	selectWindow(list[i] + " - C=" + t2);
	run("Duplicate...", "duplicate");
	rename("Channel t2");
	
	//Pre-process t2
	run("Despeckle", "stack");
	run("Subtract Background...", "rolling=50");
	run("Despeckle", "stack");
	run("Despeckle", "stack");
	//Get threshold
	setAutoThreshold("Triangle dark stack");
	getThreshold(lower,upper);
	threshold=round(mask_threshold_modifier_t2*lower);
	print("Threshold t2:",list[i], threshold);
	//Threshold t1
	setThreshold(threshold, 65535);
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Triangle background=Dark black");
	rename("T2_Mask");
	run("Fill Holes", "stack");

	//Quantify number of cells
	selectWindow("T1_Mask");
	Stack.getStatistics(nPixels, mean, min, max);
	if (max!=0){
	run("3D Objects Counter", "threshold=128 slice=1 min.=10 max.=44040192 objects");
	Stack.getStatistics(nPixels, mean, min, max);
	print(list[i], "Number of dSRF cells:", max);
	}
	else{
		print(list[i], "Number of dSRF cells:", 0);
	}
	
	selectWindow("T2_Mask");
	Stack.getStatistics(nPixels, mean, min, max);
	if (max!=0){
	run("3D Objects Counter", "threshold=128 slice=1 min.=10 max.=44040192 objects");
	Stack.getStatistics(nPixels, mean, min, max);
	print(list[i], "Number of pH3 cells:", max);
	}
	else{
		print(list[i], "Number of pH3 cells:", 0);
	}
	
	imageCalculator("AND create stack", "T1_Mask","T2_Mask");
	Stack.getStatistics(nPixels, mean, min, max);
	if (max!=0){
	run("3D Objects Counter", "threshold=128 slice=1 min.=10 max.=44040192 objects");
	Stack.getStatistics(nPixels, mean, min, max);
	print(list[i], "Number of costaining cells:", max);
	}
	else{
		print(list[i], "Number of costaining cells:", 0);
	}
	
	if (!test){
	run("Close All");
	}
}

//Test mode switch
if (!test){
run("Close All");
run("Clear Results");
}

setBatchMode(false);
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("End:",year, month+1 ,dayOfMonth, hour, minute, second);