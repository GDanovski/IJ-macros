//EasyFrap
//CopyRights Georgi Todorov Danovski, Bulgaria, 2016
//https://www.facebook.com/georgi.danovski

macro "EasyFrap [q]" {
dir = getInfo("image.directory");
name = getInfo("image.filename");
name1 = dir + replace(name,".tif",".txt");
name2 = dir +"Results_" + replace(name,".tif",".txt");

run("Set Measurements...", "mean redirect=None decimal=3");
roiManager("Multi Measure");
saveAs("Results", name1);
run("Set Measurements...", "area mean min redirect=None decimal=3");
roiManager("Multi Measure");
saveAs("Results", name2);
}