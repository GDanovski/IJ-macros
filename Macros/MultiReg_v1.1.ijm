       dir = getDirectory("Choose a Directory ");
       
		Dialog.create('Registration Settings');
		Dialog.addNumber('Reference frame:', 1);
		Dialog.addChoice('N channels:', newArray('1','2'), '1');
		Dialog.addChoice('Reference chanel:', newArray('1','2'), '1');
		Dialog.show();

		slice = Dialog.getNumber();
		Nchannels = Dialog.getChoice();
		channel = Dialog.getChoice();
		
		if(Nchannels == 1){
			channel = 1;
		}		
       
       setBatchMode(true);
       
       count = 0;
       countFiles(dir);
       n = 0;
       processFiles(dir);
       
       setBatchMode(false);
       print(count+" files processed");
    
       function countFiles(dir) {
          list = getFileList(dir);
          for (i=0; i<list.length; i++) {
              if (endsWith(list[i], "/"))
                  countFiles(""+dir+list[i]);
              else
                  count++;
          }
      }
    
       function processFiles(dir) {
          list = getFileList(dir);
          for (i=0; i<list.length; i++) {
              if (endsWith(list[i], "/"))
                  processFiles(""+dir+list[i]);
              else {
                 showProgress(n++, count);
                 path = dir+list[i];
                 processFile(path);
              }
          }
      }
    
      function processFile(path) {
            if (endsWith(path, ".tif")) {
            	open(path);
            	var name = File.name;
				var newDir = File.directory;
            	var matrices =newDir +"\\Ready\\"+name + ".txt";
            	
            	if(!File.exists(newDir +"\\Ready")){
					File.makeDirectory(newDir +"\\Ready");
				}
				
				//Split color chanels
				rename("Ch1");
				if(Nchannels  != 1){
					run("Make Substack...", "delete slices=1-" + nSlices + "-2");
					run("Red");				
					rename(name + "_R");
				}
				//set LUT
				selectWindow("Ch1");
				run("Green");
				rename(name + "_G");
				
				//use blured image
				if(channel==2){
					selectWindow(name + "_R");
				}
				
				run("Duplicate...", "duplicate");
				run("Gaussian Blur...", "sigma=2 stack");
				rename("Concatenated Stacks");
				setSlice(slice);
				run("MultiStackReg", "stack_1=[Concatenated Stacks] action_1=Align file_1=["+ matrices +"] stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body] save");
               	close();
               	//register the green chanel	
				run("MultiStackReg", "stack_1=["+name + "_G"+"] action_1=[Load Transformation File] file_1=["+ matrices+"] stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
				if(Nchannels  != 1){
               		run("MultiStackReg", "stack_1=["+name + "_R"+"] action_1=[Load Transformation File] file_1=["+ matrices+"] stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");			
				
					//mearging chanels
					run("Merge Channels...", "c1=["+name + "_R"+"] c2=["+name + "_G"+"] create");
					run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]");
					//save image
					name = replace(name, "_CompositeRegistred.tif", "");
					
					saveAs("Tiff", newDir +"\\Ready\\"+name+ "_CompositeRegistred.tif");
					print(name +"\\Ready\\"+ "_CompositeRegistred.tif" + " - processed!");
				}
				else{
					name = replace(name, "_Registred.tif", "");
					name = replace(name, ".tif", "");
					saveAs("Tiff", newDir +"\\Ready\\"+name+ "_Registred.tif");
					print(name +"\\Ready\\"+ "_Registred.tif" + " - processed!");
				}
				
				close();
          }
      }
