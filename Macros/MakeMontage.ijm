macro "MakeMontage[]"
{
channels = 1;//set number of color channels
width = 40;//set scale bar distance to the right border
height = 15;//set scale bar distance to the bottom border
slices =newArray(3,5,9,16,36,106,606);//Set slices

//Get image names
titles = newArray(3);
 
for (i=1; i<=nImages(); i++) 
{ 
 	selectImage(i); 
 	
 	if(indexOf(getTitle(), "_G")>-1)
 	{ 		
   		titles[0] = getTitle();    		
 	}
   	else if(indexOf(getTitle(), "_R")>-1)
   	{
   		titles[1] = getTitle();    		
   	}
}

if(channels == 2)
{
	//duplicate
	selectWindow(titles[0]);
	run("Duplicate...", "title=Ch1 duplicate");
	selectWindow(titles[1]);
	run("Duplicate...", "title=Ch2 duplicate");
	//create Composite image
	run("Merge Channels...", "c1=Ch2 c2=Ch1 create");
	titles[2] = getTitle(); 
}

for(i=0;i<3;i++)
{
	selectWindow(titles[i]);
	run("RGB Color", "slices");
	
	if(channels!=2)
	{
		i=100;	
	}
}


var command = "open";
var ind = 1;
for(c = 0; c<3;c++)
{
	
	for(i = 0; i<slices.length; i++)
	{		
		selectWindow(titles[c]);
		setSlice(slices[i]);
		title = "Ch_" + c + "_" + i;
		command = command + " image" + ind + "=" + title;
		ind++;
		run("Duplicate...", "title="+ title);
	}
	
	if(channels!=2)
	{
		c=100;
	}
}

run("Concatenate...", command);
rename("Concatenated");
if(channels == 2)
{
	run("Make Montage...", "columns="+ slices.length + " rows=3 scale=1 border=2");
}
else
{
	run("Make Montage...", "columns="+ slices.length + " rows=1 scale=1 border=2");
}
run("Properties...", "channels=1 slices=1 frames=1 unit=um pixel_width=0.23 pixel_height=0.23 voxel_depth=0.23");
//add scale bar
width = getWidth - width;
height = getHeight - height;
makeRectangle(width, height, 20, 20);
run("Scale Bar...", "width=5 height=2 font=14 color=White background=None location=[At Selection] bold hide");
run("Select None");

for(i=0;i<3;i++)
{
	selectWindow(titles[i]);
	close();
	if(channels!=2)
	{
		i=100;
	}
}

selectWindow("Concatenated");
close();
}

