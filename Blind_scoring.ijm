//Blind scoring of brightfield confocal microscopy images
//Select the folder that contains the images to process
//in a BioFormats Importer compatible format, defined by the
//file format variable below. Images are presented in a random
//order and scored 1-3 or 1-5.
//Version 1.0 23/08/2019
//By Máté Nászai

fileformat=".czi";
//Would you like five categories? 1=yes-->1-5, 0=no-->1-3
five=1;

//SCRIPT
run("Close All");
run("Clear Results");
setBatchMode(true);
//Get directory
dir=getDirectory("Choose Source");
list=getFileList(dir);

//Get files with correct format
requires("1.45s");
setOption("ExpandableArrays", true);
files=newArray;
a=0;
for (i=0; i<list.length; i++){
	if (endsWith(list[i],fileformat)){
		files[a]=list[i];
		a++;
	}
}

//If there  are files with the correct format
if (a>0){
	//Shuffle file order in files array
	mixed=shuffle(files);
	for (x=0; x<mixed.length; x++){
		setResult("Image", x, mixed[x]);
		//Open file
		run("Bio-Formats Importer", "open=[" + dir + File.separator + mixed[x] + "] color_mode=Composite rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT");
		run("Merge Channels...", "c1=[" + mixed[x] + " - C=0] c2=[" + mixed[x] + " - C=1] c3=[" + mixed[x] + " - C=2] create");
		run("Z Project...", "projection=[Sum Slices]");
		rename("Image number: " + x);
		close("Composite");
		selectWindow("Image number: " + x);
		setBatchMode("show");
		//Ask for score
		if (!five){
		score=getString("Enter score for this image: 1, 2 or 3", "2");
		score=parseInt(score);
		if (score==1 || score==2 || score==3){
	  		setResult("Score", x, score);
		} 
		else{
			Dialog.createNonBlocking("Error");
			Dialog.addMessage("Please use numbers between 1-3");
			x--;
		}
		}else{
			score=getString("Enter score for this image: 1-5", "3");
		score=parseInt(score);
		if (score==1 || score==2 || score==3 || score==4 || score==5){
	  		setResult("Score", x, score);
		} 
		else{
			Dialog.createNonBlocking("Error");
			Dialog.addMessage("Please use numbers between 1-5");
			x--;
		}
		}
		close("Image number: " + x);
	}
	filename = getString("Enter the name of the spreadsheet", "Blind_scores");
	saveAs("Results", dir + File.separator + filename + ".csv");
 	selectWindow("Results"); 
    run("Close");
}

setBatchMode(false);

//Fisher-Yates shuffle http://en.wikipedia.org/wiki/Fisher-Yates_shuffle
function shuffle(array){
n = array.length;
	while (n > 1){
		k = n*random;
		n--;
		temp = array[n];
		array[n] = array[k]; 
		array[k] = temp;
	}
return array;
}

