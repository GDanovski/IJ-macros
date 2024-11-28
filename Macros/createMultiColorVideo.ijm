// Copyright (c) 2024 Georgi Danovski
// This macro is licensed under the MIT License.

// This macro will process each open image, split the color channels, 
// merge them back together, create a result image, add text and a 
// scale bar, and save the result as an AVI file. Adjust the paths,
// settings, and processing steps as needed for your specific use case.

// Show a dialog to choose font type, size, and time unit
Dialog.create("Font Settings");
fontTypes = newArray("SansSerif", "Serif", "Monospaced");
Dialog.addChoice("Font Type:", fontTypes, "SansSerif");
Dialog.addNumber("Font Size:", 8);
timeUnits = newArray("sec", "min");
Dialog.addChoice("Time Unit:", timeUnits, "min");
decimalDigitTypes = newArray("true", "false");
Dialog.addChoice("Always show decimal digits:", decimalDigitTypes, "true");
Dialog.addString("Protein 1:", "RAD18");
Dialog.addString("Protein 2:", "PCNA");
Dialog.addNumber("Error bar width:", 25);
Dialog.addNumber("Error bar height:", 12);
Dialog.addNumber("Image scale:", 4);
Dialog.addNumber("Frames before HU:", 30);
Dialog.addNumber("Frames in HU", 120);
Dialog.addNumber("From that frame the frames ar 1 min, not 30 sec.", 30 + 120 + 120);
Dialog.addString("Inhibitors:", "AZD+KU");

Dialog.show();

// Retrieve dialog inputs
fontType = Dialog.getChoice();
fontSize = Dialog.getNumber();
timeUnit = Dialog.getChoice();
showDecimalDigit = Dialog.getChoice();
protein1 = Dialog.getString();
protein2 = Dialog.getString();
errorBarWidth = Dialog.getNumber();
errorBarHeight = Dialog.getNumber();
imageScale = Dialog.getNumber();
framesBeforeHu = Dialog.getNumber();
imageInHu = Dialog.getNumber();
borderTime = Dialog.getNumber();
inhibitors = Dialog.getString();

// Adjust font size and error bar dimensions based on image scale
fontSize *= imageScale;
errorBarWidth *= imageScale;
errorBarHeight *= imageScale;

// Function to replace the extension of a file
function replaceExtension(filePath, newExtension) {
    // Find the position of the last dot in the file path
    dotIndex = lastIndexOf(filePath, ".");
    
    // If a dot is found, replace the extension
    if (dotIndex != -1) {
        return substring(filePath, 0, dotIndex) + newExtension;
    } else {
        // If no dot is found, append the new extension
        return filePath + newExtension;
    }
}

// Get the list of open images
imageIDs = getList("image.titles");
setBatchMode(true);

// Loop through each open image
for (i = 0; i < imageIDs.length; i++) {
    // Select the image
    selectWindow(imageIDs[i]);
    
    // Get the title of the current image
    title = getTitle();
    
    // Get the directory of the current image
    path = getInfo("image.directory") + replaceExtension(title, ".avi");
    
    // Skip images with titles containing "_G.tif"
    if (indexOf(title, "_G.tif") != -1) {
        continue; // Skip to the next iteration
    }
    
    // Split color channels
    rename("Ch1");
    selectWindow(replace(title, "_R.tif", "_G.tif"));
    rename("Ch2");
    
    // Set LUT for the first channel (Red)
    selectWindow("Ch1");
    rename(title + "_R1");
    run("Duplicate...", "duplicate slices=" + nSlices);
    rename(title + "_R");
    
    // Set LUT for the second channel (Green)
    selectWindow("Ch2");
    rename(title + "_G1");
    run("Duplicate...", "duplicate slices=" + nSlices);
    rename(title + "_G");
    
    // Merge the channels back together
    run("Merge Channels...", "c1=[" + title + "_R1" + "] c2=[" + title + "_G1" + "] create ignore");
    rename(title);
    
    // Convert the channels to RGB
    selectWindow(title + "_G");
    run("RGB Color");
    selectWindow(title);
    run("Stack to RGB", "slices");
    selectWindow(title + "_R");
    run("RGB Color");
    
    // Create a new image to show the first, merged, and second images side by side
    width = getWidth();
    height = getHeight();
    newImage(title + "_result", "RGB black", width * 3, height, nSlices);
    setForegroundColor(255, 255, 255);
    setBackgroundColor(0, 0, 0);
    rename(title + "_result");
    
    // Loop through each frame
    for (frame = 1; frame <= nSlices; frame++) {
        selectWindow(title + "_result");
        setSlice(frame);
        
        // Draw the first image (green channel)
        selectWindow(title + "_G");
        setSlice(frame);
        run("Select All");
        run("Copy");
        selectWindow(title + "_result");
        makeRectangle(0, 0, width, height);
        run("Paste");
        
        // Draw the composite image
        selectWindow(title);
        setSlice(frame);
        run("Select All");
        run("Copy");
        selectWindow(title + "_result");
        makeRectangle(width, 0, width, height);
        run("Paste");
        
        // Draw the second image (red channel)
        selectWindow(title + "_R");
        setSlice(frame);
        run("Select All");
        run("Copy");
        selectWindow(title + "_result");
        makeRectangle(width * 2, 0, width, height);
        run("Paste");
    }
    
    // Scale the result image
    width *= imageScale * 3;
    height *= imageScale;
    selectWindow(title + "_result");
    rename(title + "_result1");
    run("Select None");
    run("Scale...", "x=" + imageScale + " y=" + imageScale + " z=1.0 width=" + width + " height=" + height + " depth=330 interpolation=None process create");
    rename(title + "_result");
    selectWindow(title + "_result1");
    close();
    
    selectWindow(title + "_result");
    errorBarWidth = getWidth() - errorBarWidth;
    errorBarHeight = getHeight() - errorBarHeight;
    
    // Loop through each frame to add text and scale bar
    for (frame = 1; frame <= nSlices; frame++) {
        selectWindow(title + "_result");
        setSlice(frame);
        
        // Set the font size and color to white
        setFont(fontType, fontSize);
        setColor(255, 255, 255); // Set color to white
        
        // Calculate the time in sec
        time = frame - 1;
        border = borderTime;
        if (time <= border) {
            time = time * 30;
        } else {
            time = border * 30 + (time - border) * 60;
        }

		// recalculate the time per phase
		withTime = true;
        if (frame <= framesBeforeHu) {
        	time = 0;
        	withTime = false;
        }
        else if (frame <=imageInHu+framesBeforeHu) {
        	time -= framesBeforeHu*30;
        }
        else {
        	time -= framesBeforeHu*30 + imageInHu*30;
        }
        
        // convert time from s to min
        if (timeUnit == "min") {
            time /= 60;
        }
        
        // Write text to the images
        text = "" + time;
        
        // Find the position of the decimal point
        decimalPos = indexOf(text, ".");
        if (decimalPos == -1 && showDecimalDigit == "true") {
            text += ".0";
        }
        text += " " + timeUnit;
        
        // Draw string to the image
        xPos = 2;
        xPosTime = width / 3 - 4 - getStringWidth(text);
        yPosProtNames = height - 2;
        yPos = fontSize + 2;
        
        curInibitors = inhibitors;
        if (frame >framesBeforeHu && frame <=imageInHu+framesBeforeHu) {
        	curInibitors += "+HU";
        }
        
        if (withTime == true) {
        	drawString(text, xPos + xPosTime, yPos);
        }
        drawString(curInibitors, xPos, yPos);
        drawString(protein1, xPos, yPosProtNames);
        xPos += width / 3;
        if (withTime == true) {
        	drawString(text, xPos+ xPosTime, yPos);
        }
        drawString(curInibitors, xPos, yPos);
        drawString("Merged", xPos, yPosProtNames);
        xPos += width / 3;
        if (withTime == true) {
        	drawString(text, xPos+ xPosTime, yPos);
        }
        drawString(curInibitors, xPos, yPos);
        drawString(protein2, xPos, yPosProtNames);
        drawString("5 µm", errorBarWidth, yPosProtNames);
        
        // Add scale bar
        makeRectangle(errorBarWidth, errorBarHeight, 20, 20);
        run("Properties...", "channels=1 slices=" + nSlices + " frames=1 unit=um pixel_width=" + (0.23 / imageScale) + " pixel_height=" + (0.23 / imageScale) + " voxel_depth=" + (0.23 / imageScale));
        run("Scale Bar...", "width=5 height=" + (2 * imageScale) + " font=" + fontSize + " color=White background=None location=[At Selection] bold hide");
        run("Select None");
    }
    
    // Close the split channel images
    selectWindow(title + "_R");
    close();
    selectWindow(title);
    close();
    selectWindow(title + "_G");
    close();
    selectWindow(title + "_result");
    run("AVI... ", "compression=JPEG frame=10 save=[" + path + "]");
    //run("AVI... ", "compression=None frame=10 save=[" + replaceExtension(path, "_None.avi") + "]");
    print("File saved: " + path);
}

setBatchMode(false);