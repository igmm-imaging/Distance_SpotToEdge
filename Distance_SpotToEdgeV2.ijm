// A Script that measures minimum length between spot of interest and nucleus edge
// Language: ImageJ Macro
// Authors: Matt Pearson and Ahmed Fetit
// Imaging Resource, HGU, IGMM.
// Updated: 09/10/2015.

imagename = getTitle();
run("Duplicate...", "title=Duplicate");
selectWindow(imagename);
run("Split Channels");
channels=3;
ch = newArray(channels);
ch0 = getImageID;
for (i=0; i<channels; i++){
ch[i] = ch0+i;
}

//Dialogue to choose between Green and Red channels
Dialog.create("New Image");
Dialog.addChoice("Type:", newArray("Green", "Red"));
Dialog.show();
type = Dialog.getChoice();

//initialise selectedCh variable
selectedCh=ch[1];

setTool("brush");
call("ij.gui.Toolbar.setBrushSize", 15); 

//If selected channel is Green, close red window, and vice versa
if (type=="Green") {selectedCh=ch[1]; selectImage(ch[2]); close(); }
else { selectedCh=ch[2]; selectImage(ch[1]); close();}
        
setBatchMode("Exit and Display");
run("Tile");
waitForUser("Spot selection: \n Hold shift to mark one spot on the channel\n Click OK when you're done");
selectImage(selectedCh);

getSelectionCoordinates(xPoints,yPoints);//Gets coordinates of the selected point
x = xPoints[0]; y = yPoints[0];
showMessage("Got coordinates ("+x+","+y+")"); 

setAutoThreshold("Default dark");//Thresholds point of interest
run("Set Measurements...", "center limit add redirect=None decimal=2");
run("Analyze Particles...", "size=5-200 show=[Overlay Outlines] display include add");

//Red Channel
//selectImage(ch[2]);
//setAutoThreshold("Default dark");
//run("Analyze Particles...", "size=5-200 show=[Overlay Outlines] display include add");

//Blue Channel
run("Colors...", "foreground=white background=white selection=yellow");
selectImage(ch[0]);
setAutoThreshold("Huang dark"); //Thresholds the shell in blue channel
run("Analyze Particles...", "size=2000-Infinity include add");

roiManager("Select", 0);
run("Create Mask");
roiManager("Select", 1);
run("Create Mask");
getSelectionCoordinates(xPoints1,yPoints1); //Get the x and y coordinates of the shell. This throws everything in an array
//x1 = xPoints1[100]; y1 = yPoints1[100]; //Just a test to see if it works; by spitting out one pair (e.g. 100th x/y pair). 
//You can visualise this pair on the image by using Edit->Selection->Specify. The point lies on the bounadry of the shell.
//showMessage("Got coordinates ("+x1+","+y1+")");




arrayLengths=newArray; //Array that keeps lengths of all drawn lines


//---------------Draws a line from the selected point (x,y) to all coordinates on the shell boundary (xPoints1, yPoints1).
for (i=0; i<lengthOf(xPoints1); i++)
{
//The makeline function can be used if you need to use ImageJ's built-in functions that get results using "measure"	
//makeLine(xPoints1[i], yPoints1[i], x, y);
//Instead of using makeline we use simple calculation to get length given two coordinates
length= sqrt((x-xPoints1[i])*(x-xPoints1[i])+(y-yPoints1[i])*(y-yPoints1[i]));
//print (length);
arrayLengths = Array.concat(arrayLengths, length);
//The concat function adds element to the end of the array
//which makes sure the array is populated with all the measured lengths
//run("Measure");
}

// //This prints the contents of the array holding all lengths
//Array.print(arrayLengths);

//----------------The following calculates the maximum and minimum distances from the point to the shell-------

N = lengthOf(xPoints1); //Number of results 
max_Length=0;
min_Length=0;

//Max value in "Length" column
for (a=0; a<N; a++) {
    if (arrayLengths[a]>max_Length)
    {
     max_Length = arrayLengths[a];
    	}
    	else{};
}

//Min value in "Length" column (note: requires max value)
min_Length=max_Length;
for (a=0; a<N; a++) {
    if (arrayLengths[a]<min_Length)
    {
     min_Length = arrayLengths[a];
    	}
    	else{};
}

//showMessage("Minimum and Maximum Length ("+min_Length+","+max_Length+")");
//print(imagename);
//print (min_Length);

LengthToCircRatio = min_Length/N;

print(imagename+", "+type+", "+min_Length+", "+N+", "+LengthToCircRatio);
xPoints = 0; //Re-sets xPoints and yPoints; otherwise it gets confused when new images are used
yPoints = 0;
run("Clear Results");

if (isOpen("ROI Manager"))
{
     selectWindow("ROI Manager");
     run("Close");
}

//Prompt user and close all images
waitForUser("Close all?");
while (nImages>0) 
{ 
	selectImage(nImages); 
	close(); 
}

if (isOpen("Results"))
{
     selectWindow("Results");
     run("Close");
}

selectWindow("Log");
saveAs("Text", "\\\\cmvm.datastore.ed.ac.uk\\cmvm\\smgphs\\users\\afetit\\Win7\\Desktop\\Stats.csv");


//minima = Array.findMinima(arrayLengths, 0)
//print(arrayLengths[minima])


//-------------------------------This uses ImageJ's Results Table (Length Field) -------------------------------
//printArray(arrayLengths);

//N = nResults; //Number of results 
//max_Length=0;
//min_Length=0;
//
//Max value in "Length" column
//for (a=0; a<nResults(); a++) {
//    if (getResult("Length",a)>max_Length)
//    {
//     max_Length = getResult("Length",a);
//    	}
//    	else{};
//}
//
////Min value in "Length" column (note: requires max value)
//min_Length=max_Length;
//for (a=0; a<nResults(); a++) {
//    if (getResult("Length",a)<min_Length)
//    {
//     min_Length = getResult("Length",a);
//    	}
//    	else{};
//}
//
//showMessage("Minimum and Maximum Length ("+min_Length+","+max_Length+")");
