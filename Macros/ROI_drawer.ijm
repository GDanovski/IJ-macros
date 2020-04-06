//ROI_drawer
//CopyRight Georgi Todorov Danovski, Bulgaria, 2016
//https://www.facebook.com/georgi.danovski

//create dialog
if (nImages > 0){
run("ROI Manager...");
count = roiManager("count");
if (count > 0) {
Dialog.create("ROI drawer");

ar = newArray();
for (i=0; i<=(count - 1); i++) {
ar = Array.concat(ar,i);
}

Dialog.addChoice("Select ROI:", ar, "0.0");
items = newArray("cyan", "white", "red", "blue", "magenta", "yellow", "black");
jj = Dialog.addRadioButtonGroup("Choose color:", items, 2, 2, "white");
Dialog.addMessage("Select ROI and press OK");
Dialog.show;
//convert to RGB color
run("RGB Color");
//choose ROI color
col = Dialog.getRadioButton();
roi = parseInt(Dialog.getChoice());
if (col == "white") {
	run("Colors...", "foreground=white background=black selection=yellow");
	}
if (col == "cyan") {
	run("Colors...", "foreground=cyan background=black selection=yellow");
	}
	if (col == "red") {
	run("Colors...", "foreground=red background=black selection=yellow");
	}
	if (col == "blue") {
	run("Colors...", "foreground=blue background=black selection=yellow");
	}
	if (col == "magenta") {
	run("Colors...", "foreground=magenta background=black selection=yellow");
	}
	if (col == "yellow") {
	run("Colors...", "foreground=yellow background=black selection=yellow");
	}
	if (col == "black") {
	run("Colors...", "foreground=black background=black selection=yellow");
	}
//add ROI to all frames
roiManager("Select", roi);
 Roi.getBounds(x,y,w,h);
for (i=1; i<=nSlices; i++) { 
		setSlice(i);
	  	drawOval(x,y,w,h); 
	     }
print("Done!");
}
else {
	print("Add ROI!");
}
}
else {
print("There is no image open!");
}