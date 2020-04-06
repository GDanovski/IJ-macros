macro "ImportImage[]"
{
	var channels = 1;//set number of color channels
	
	var name = File.name;
	var dir = File.directory;
	if(channels == 2)
	{
		//Split color chanels
		rename("Ch1");
		run("Make Substack...", "delete slices=1-" + nSlices + "-2");
		rename("Ch2");
		//set LUT
		selectWindow("Ch1");
		run("Red");
		rename(name + "_R");
		selectWindow("Ch2");
		run("Green");
		rename(name + "_G");
	}
	else
	{
		//set LUT
		run("Green");
		rename(name + "_G");
	}
	//Open B&C
	run("Brightness/Contrast...");
}