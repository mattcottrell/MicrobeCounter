
// ############################ Start of Script 2 ########################################


	// Macro counting Dead, Live and Total Yeast cells
	
//Call this macro like this...
//"C:\Users\Cottrell\Documents\Fiji.app\ImageJ-win64.exe" --ij2 --console -macro "C:\Users\Cottrell\Documents\YeastCounter\Live_Dead_Total_Yeast_v2.ijm" "C:/Users/Cottrell/Pictures/Cellpose/Test2/#Sample1"

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

// Arrays used for display and debugging not data handling
arrayTY = newArray(11);
arrayLY = newArray(11);
arrayDY = newArray(11);

for(fieldnumber=1;fieldnumber<=10;fieldnumber++){

	// This should help with readability as the data scroll by in the log
	arrayTY[0] = fieldnumber;
	arrayLY[0] = fieldnumber;
	arrayDY[0] = fieldnumber;

	// ************************************************************************************
	//   Count TY in the mask made previously by combining the Cellpose and threshold masks
	// ************************************************************************************

	// Open the TY CP mask with outlines
	open(path +	samplename + "_TY" +"/" + samplename + "_field_" + fieldnumber + "_TY_Mask.tif");

	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('" + samplename + "_field_" + fieldnumber + "_TY_Mask.tif');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);
		
	//Burn in the outlines to separate touching cells (very helpful)
	open(path +	samplename + "_CP_OUT" +"/" + samplename + "_field_" + fieldnumber + "_outlines.png");
	
	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('" + samplename + "_field_" + fieldnumber + "_outlines.png');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);

	run("8-bit");
	run("Subtract...", "value=1");
	run("Multiply...", "value=255.000");
	run("Invert");

	imageCalculator("AND create", samplename + "_field_" + fieldnumber + "_TY_Mask.tif",samplename + "_field_" + fieldnumber + "_outlines.png");

	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('Result of " + samplename + "_field_" + fieldnumber + "_TY_Mask.tif');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);

	selectWindow("Result of " + samplename + "_field_" + fieldnumber + "_TY_Mask.tif");

	// Save a tiff version
	saveAs("Tiff", path + "/" + samplename + "_TY" + "/" + samplename + "_field_" + fieldnumber + "_TY_With_Outlines_Mask.tif");

	selectWindow(samplename + "_field_" + fieldnumber + "_TY_With_Outlines_Mask.tif");
	setAutoThreshold("Default dark no-reset");

	run("Convert to Mask");
	run("Set Scale...", "distance=7.3043 known=1 unit=micron");
	run("Analyze Particles...", "size=10-100 circularity=0.60-1.00 show=Masks display clear");

	arrayArea = Table.getColumn("Area");
 	arrayTY[fieldnumber] = arrayArea.length;
	print("TY");
	Array.print(arrayTY);

	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('Mask of " + samplename + "_field_" + fieldnumber + "_TY_With_Outlines_Mask.tif');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);

	saveAs("Tiff", path + "/" + samplename + "_TY" + "/" + samplename + "_field_" + fieldnumber + "_TY_Count_Result_Mask.tif");

	// Save the TY count and size data
	saveAs("Results", path + samplename + "_TY/" + samplename + "_field_" + fieldnumber + "_TY.csv");

	//waitForUser("Wait 1", "TY mask has been made and saved");

	run("Close All");
	
	// ******************************
	// DY are counted in the TH mask
	// ******************************
	
	open(path + samplename + "_TH_OUT" + "/" + samplename + "_field_" + fieldnumber + "_TH_Mask.tif");

	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('" + samplename + "_field_" + fieldnumber + "_TH_Mask.tif');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);

	run("Set Scale...", "distance=7.3043 known=1 unit=micron");
	
	//waitForUser("Wait 2", "Ready to count DY");
	
	run("Invert");
	run("Analyze Particles...", "size=10-100 circularity=0.60-1.00 show=Masks display clear");
	
	// Handle instances where there are no dead cells
	blnAreaColumnExists = Table.columnExists("Area");
	
	if( blnAreaColumnExists == "True" )
	{
		arrayArea = Table.getColumn("Area");
		arrayDY[fieldnumber] = arrayArea.length;
	}
	else{
		arrayDY[fieldnumber] = 0;
	}
	
	print("DY");
	Array.print(arrayDY);
	
	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('Mask of " + samplename + "_field_" + fieldnumber + "_TH_Mask.tif');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);

	//waitForUser("Wait 3", "DY counted");
	
	// Make the directory for saving DY
	File.makeDirectory (path + "/" + samplename + "_DY");
	
	// Save the DY count and size data
	saveAs("Results", path + samplename + "_DY/" + samplename + "_field_" + fieldnumber + "_DY.csv");
	
	// Save the LY mask
	saveAs("Tiff", path + samplename + "_DY/" + samplename + "_field_" + fieldnumber + "_DY_Count_Result_Mask.tif");

	//waitForUser("Wait 4", "DY mask has been made, counted and saved");

	run("Clear Results");
	run("Close All");
	
	// **********************************************************************************************************
	// Live yeast (LY) are counted after removing DY from the TY mask using a morphologica reconstruction and XOR
	// **********************************************************************************************************S
	
	// Make the directory for saving LY
	File.makeDirectory (path + "/" + samplename + "_LY");
	
	open(path + samplename + "_DY/" + samplename + "_field_" + fieldnumber + "_DY_Count_Result_Mask.tif");

	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('" + samplename + "_field_" + fieldnumber + "_DY_Count_Result_Mask.tif');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);

	run("Invert LUT");
	run("Invert");

	open(path + samplename + "_TY/" + samplename + "_field_" + fieldnumber + "_TY_Count_Result_Mask.tif");
  
	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('" + samplename + "_field_" + fieldnumber + "_TY_Count_Result_Mask.tif');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);
	
	run("Invert LUT");
	run("Invert");

	//waitForUser("Wait 5", "Ready for morphological reconstruction");

	run("Morphological Reconstruction", "marker=" + samplename + "_field_" + fieldnumber + "_DY_Count_Result_Mask.tif mask=" + samplename + "_field_" + fieldnumber + "_TY_Count_Result_Mask.tif type=[By Erosion] connectivity=8");

	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('" + samplename + "_field_" + fieldnumber + "_DY_Count_Result_Mask-rec');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);

	//waitForUser("Wait 6", "Ready for XOR");
	imageCalculator("XOR create", samplename +"_field_" + fieldnumber + "_DY_Count_Result_Mask-rec",samplename + "_field_" + fieldnumber + "_TY_Count_Result_Mask.tif");

	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('Result of " + samplename + "_field_" + fieldnumber + "_DY_Count_Result_Mask-rec');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);

	selectWindow("Result of " + samplename + "_field_" + fieldnumber + "_DY_Count_Result_Mask-rec");
	run("Invert");
	run("Set Scale...", "distance=7.3043 known=1 unit=micron");
	
	//waitForUser("Wait 7", "Ready for LY  count");
	run("Analyze Particles...", "size=10-100 circularity=0.60-1.00 show=Masks display clear");

	arrayArea = Table.getColumn("Area");
 	arrayLY[fieldnumber] = arrayArea.length;
	print("LY");
	Array.print(arrayLY);

	run("Set... ", "zoom=50 x=944 y=944");
		script = 
		"lw = WindowManager.getWindow('Mask of Result of " + samplename + "_field_" + fieldnumber + "_DY_Count_Result_Mask-rec');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(865,92);\n"+
		"}\n";
	eval("script", script);

	saveAs("Results", path + samplename + "_LY/" + samplename + "_field_" + fieldnumber + "_LY.csv");
	saveAs("Tiff", path + samplename + "_LY/" + samplename + "_field_" + fieldnumber + "_LY_Count_Result_Mask.tif");
	run("Clear Results");
	run("Close All");
}

run("Quit");

