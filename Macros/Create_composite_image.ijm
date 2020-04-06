//CellTool helper
//CopyRights Georgi Todorov Danovski, Bulgaria, 2016
//https://www.facebook.com/georgi.danovski
//Check for Z projection
var z = "0";
Dialog.create("Create composite image");
Dialog.addString("Z stack: ", "3");
Dialog.show;
z = Dialog.getString();
//check for open images
if (nImages > 0) {
//list the images
listImages = newArray();
for (i=1; i<=nImages; i++) {
selectImage(i);
listImages = Array.concat(listImages, getTitle());
}
//get the directory of the image
//var Directory = getDirectory(listImages[0]);
//Maximum intensity projection by usin Group ZProjector
if (z == "0") {
for (i=0; i<listImages.length; i++) {
	var Name = listImages[i];
	selectWindow(Name);
    run("Grouped ZProjector", "group=" + z + " projection=[Max Intensity]");
    //close the initial image
    selectWindow(Name);
    close();
    //rename the image to the old name
    selectWindow("Projection of " + Name);
    rename(Name);
}
print("Z stack = " + z);
print("Maximum intensiti projection - done");
}
else {
print("Z stack = 0");
}
//Sort images by color
ListG = newArray();
ListR = newArray();
for (i=0; i < listImages.length; i++) {
	if (indexOf(listImages[i],"w0000")>-1) {
		ListG = Array.concat(ListG,listImages[i]);
	}
	if (indexOf(listImages[i],"w0001")>-1) {
		ListR = Array.concat(ListR,listImages[i]);
	}
}
//Concatenate images
// Green
if (ListG.length > 0) {
print("Chanel 1 detected");
}
if (ListG.length > 1) {
	Array.sort(ListG);
	run("Concatenate...", "  title=[1] image1=[" + ListG[0] + "] image2=[" + ListG[1] +"] image3=[-- None --]");
	print("Chanel 1 concatenated");
}
if (ListG.length == 1) {
	selectWindow(ListG[0]);
	rename("1");
}
//Red
if (ListR.length > 0) {
print("Chanel 2 detected");
}
if (ListR.length > 1) {
	Array.sort(ListR);
	run("Concatenate...", "  title=[2] image1=[" + ListR[0] + "] image2=[" + ListR[1] +"] image3=[-- None --]");
	print("Chanel 2 concatenated");
	}
if (ListR.length == 1) {
	selectWindow(listR[0]);
	rename("2");
}
//If the image is single chanel
if (ListG.length < 1) {
	print("Single chanel image detected");
	if (listImages.length == 2) {
	run("Concatenate...", "  title=[ReadyForCut] image1=[" + listImages[0] + "] image2=[" + listImages[1] +"] image3=[-- None --]");
	print("Single chanel image concatenated");
	}
	else {
		selectWindow(listImages[0]);
		rename("ReadyForCut");
	}
}
else {
	run("Merge Channels...", "c1=2 c2=1 create");
	selectWindow("Composite");
	rename("ReadyForCut");
    print("Composite file created");
}
//  Delete last slice
selectWindow("ReadyForCut");
setSlice(nSlices);
run("Delete Slice", "delete=slice");
print("Last frame deleted");
print("Done!");
}
else {
	print("There is no open images!");
}