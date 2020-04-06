input = "C:/Users/georg/Desktop/MDC1_test/input/";
output = "C:/Users/georg/Desktop/MDC1_test/output/";

list = getFileList(input);
for (i = 0; i < list.length; i++)
        action(input, output, list[i]);

function action(input, output, filename) {
open(input + filename);


run("Duplicate...", "duplicate");
run("Smooth", "stack");
run("Green Fire Blue");
saveAs("Tiff", output + "Smooth_RGB_" + filename);
close();
selectWindow(filename);
run("Duplicate...", "duplicate");
run("Gaussian Blur...", "sigma=2 stack");
run("Green Fire Blue");
saveAs("Tiff", output + "Gaus_2_RGB_"  + filename);
close();
selectWindow(filename);
close();
}

