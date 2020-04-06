//Add ROI
//CopyRights Georgi Todorov Danovski, Bulgaria, 2016
//https://www.facebook.com/georgi.danovski
Dialog.create("Add ROI");
Dialog.addNumber("x: ", 10);
Dialog.addNumber("y: ", 10);
Dialog.addNumber("width: ", 1);
Dialog.addNumber("Height: ", 1);
Dialog.show;
x = Dialog.getNumber();
y = Dialog.getNumber();;
w = Dialog.getNumber();;;
h = Dialog.getNumber();;;;
run("ROI Manager...");
roiManager("Show All");
makeOval(x,y,w,h);
roiManager("add");