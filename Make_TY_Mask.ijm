
// ############################  Start of Script 1 ########################################

//Call this macro like this...
//"C:\Users\Cottrell\Documents\Fiji.app\ImageJ-win64.exe" --ij2 --console -macro "C:\Users\cottrell\Documents\MicrobeCounter\Make_TY_Mask.ijm" "C:/Users/Cottrell/Pictures/Test/#foo"

arg = getArgument();
print(arg);
foo = split(arg,"#")

// # path #
print(foo[0])
path = foo[0]

// # samplename #
print(foo[1])
samplename = foo[1]

//path = "C:/Users/cottrell/Pictures/Test/";
//samplename = "foo";
//fieldnumber = 1;

	// ********************************************
	//              Make the TY IJ Mask
	// ********************************************

for(fieldnumber=1;fieldnumber<=10;fieldnumber++){
		
	// ****************
	// Threshold the DY
	// ****************

	// Open the original image
	open(path + samplename + "_field_" + fieldnumber + ".tif");
	
	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('" + samplename + "_field_" + fieldnumber + ".tif');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);

	run("8-bit");
	setAutoThreshold("Default dark no-reset");

	// Try min=75 to detect more dead cells in sample of OYL-011 (AKA LA3, WY1318)
	run("Manual Threshold...", "min=75 max=255");
	//run("Manual Threshold...", "min=63 max=255");
	
	setOption("BlackBackground", false);

	run("Convert to Mask");
	run("Invert LUT");
	run("Invert");
	run("Dilate");
	run("Dilate");
	run("Dilate");
	run("Erode");
	run("Erode");
	run("Erode");


	
	//waitForUser("Wait A", "Next  open _cp_masks.png");
	
	// Save the thresholded mask
	File.makeDirectory (path + "/" + samplename + "_TH_OUT");
	saveAs("Tiff", path + samplename + "_TH_OUT" + "/" + samplename + "_field_" + fieldnumber + "_TH_Mask.tif");

	// *********************************************************************
	// Make the TY mask using an OR of the DY IJ mask and the LY CP masks
	// *********************************************************************
	
	//waitForUser("Wait 1", "Next  open _cp_masks.png");
	
	// Open the LY CP mask
	open(path +	samplename + "_CP_OUT" + "/" + samplename + "_field_" + fieldnumber + "_cp_masks.png");
	
	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('" + samplename + "_field_" + fieldnumber + "_cp_masks.png');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);
	
	run("Invert LUT");
	
	//waitForUser("Wait 1", "Inverted");
	
	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('Result of " + samplename + "_field_" + fieldnumber + "_cp_masks.png');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);
	
	//waitForUser("Wait 1", "Inverted moved");
	
	setOption("ScaleConversions", true);
	run("8-bit");
	run("Multiply...", "value=255");
	
	imageCalculator("OR create", samplename + "_field_" + fieldnumber + "_TH_Mask.tif", samplename + "_field_" + fieldnumber + "_cp_masks.png");

	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('Result of " + samplename + "_field_" + fieldnumber + "_TH_Mask.tif');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);

	//waitForUser("Wait B", "Next  open _cp_masks.png");

	File.makeDirectory (path + "/" + samplename + "_TY");
	
	selectWindow("Result of " + samplename + "_field_" + fieldnumber + "_TH_Mask.tif");
	
	saveAs("Tiff", path + "/" + samplename + "_TY" + "/" + samplename + "_field_" + fieldnumber + "_TY_Mask.tif");

	//waitForUser("Wait B", "Next  open _cp_masks.png");

	run("Close All");
}
run("Quit");

// ############################  End of Script 1 ########################################
