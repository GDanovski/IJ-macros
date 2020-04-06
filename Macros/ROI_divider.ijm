//ROI_divider

//CopyRights Georgi Todorov Danovski, Bulgaria, 2016

//https://www.facebook.com/georgi.danovski



//check for active image

if (nImages > 0){
//check for ROIs

run("ROI Manager...");
count = roiManager("count");
if (count > 1) {
//create dialog box

Dialog.create("ROI divider");
ar = Array.getSequence(count);
Dialog.addChoice("Outside ROI:", ar, "0.0");
Dialog.addChoice("Inside ROI:", ar, "1.0");
Dialog.addCheckbox("All frames", true);
Dialog.show;
//take dialog variables

roiChoice2 = Dialog.getChoice();
roiChoice1 = Dialog.getChoice();;
allFrames = Dialog.getCheckbox();
roi1 = parseInt(roiChoice1);
roi2 = parseInt(roiChoice2);
//take outside roi dimentions

roiManager("Select", roi2);
Roi.getBounds(x, y, width, height);
//set firs and last frame for the measurments

begin = getSliceNumber();
end = nSlices;
if (allFrames == false) {
		//set the measurments for current frame

		begin = getSliceNumber();
		end = getSliceNumber();
}
else {
		//set the measurments for all frame

		begin = 1;
		end = nSlices;	
}
// lists with the coordinates for pixels in area roi2 - roi1

xlist = newArray();

ylist = newArray();

// lists with the coordinates for pixels in area roi1

xlist1 = newArray();

ylist1 = newArray();

//Find the pixels for the lists

for (ix=x - 1; ix<(x + 1 +width); ix++) {

		for (iy=y - 1; iy<(y + 1 +width); iy++) {

				roiManager("Select", roi2);

				if (Roi.contains(ix, iy) == 1){

					roiManager("Select", roi1);

					if (Roi.contains(ix, iy) != 1){

        			xlist = Array.concat(xlist,ix);

        			ylist = Array.concat(ylist,iy);

					}

				else{

	    			xlist1 = Array.concat(xlist1,ix);

       				ylist1 = Array.concat(ylist1,iy);

					}

				}

				}

}

//calculate statistics for all frames

for (i=begin; i<=end; i++) { 
		setSlice(i);
		res = newArray();

		res1 = newArray();

		for (ii=0; ii<=(xlist.length-1); ii++) {

				res = Array.concat(res, getPixel(xlist[ii], ylist[ii]));

		}

		for (ii=0; ii<=(xlist1.length-1); ii++) {

				res1 = Array.concat(res1, getPixel(xlist1[ii], ylist1[ii]));

		}

		//Get statistics

		Array.getStatistics(res1, min1, max1, mean1, stdDev1);
		Array.getStatistics(res, min, max, mean, stdDev);
		//Prepare results

		row = nResults;
		setResult("Area1", row, res1.length);
		setResult("Mean1", row, mean1);
		setResult("Min1", row, min1);
		setResult("Max1", row, max1);
		setResult("Area2", row, res.length);
		setResult("Mean2", row, mean);
		setResult("Min2", row, min);
		setResult("Max2", row, max);
		}
		//show results table

		updateResults();

}
else {
	print("There is no added ROIs!");
}
}
else {
	print("There is no image opened!");
}
