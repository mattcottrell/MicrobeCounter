
//Call this macro like this...
//"C:\Users\Cottrell\Documents\Fiji.app\ImageJ-win64.exe" --ij2 --console -macro "C:\Users\Cottrell\Documents\Fiji.app\plugins\review_LY_DY_overlays.ijm" "C:/Users/Cottrell/Pictures/Cellpose/Test2/#Sample1"

arg = getArgument();
print(arg);
foo = split(arg,"#")

// *path*
print(foo[0])
path = foo[0]

// *samplename*
print(foo[1])
samplename = foo[1]


//path = "C:/Users/cottrell/Pictures/FV5/";
//samplename = "FV5-1";
//fieldnumber = 1;

//for(fieldnumber=1;fieldnumber<=10;fieldnumber++){


//fieldnumber = " + fieldnumber + ";

for(fieldnumber=1;fieldnumber<=10;fieldnumber++){

	open(path + samplename + "_field_" + fieldnumber + ".tif");
	run("Set... ", "zoom=50 x=944 y=944");
	script = 
		"lw = WindowManager.getActiveWindow();\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(394,92);\n"+
		"}\n";
	eval("script", script);
	//waitForUser("Field" + " " + fieldnumber, "      eval 1");
		
	 //////waitForUser("Field" + " " + fieldnumber, "Did the window move lower right?");

	open(path + samplename + "_DY/" + samplename + "_field_" + fieldnumber + "_DY_Count_Result_Mask.tif");
	run("Set... ", "zoom=50 x=944 y=944");
	script = 
		"lw = WindowManager.getActiveWindow();\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(394,92);\n"+
		"}\n";
	eval("script", script);
	//waitForUser("Field" + " " + fieldnumber, "      eval 2");

	open(path + samplename + "_LY/" + samplename + "_field_" + fieldnumber + "_LY_Count_Result_Mask.tif");
	run("Set... ", "zoom=50 x=944 y=944");
	script = 
		"lw = WindowManager.getWindow('" + samplename + "_field_" + fieldnumber + "_LY_Count_Result_Mask.tif');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(394,92);\n"+
		"}\n";
	eval("script", script);
	//waitForUser("Field" + " " + fieldnumber, "      eval 3");
	
	selectWindow("" + samplename + "_field_" + fieldnumber + "_DY_Count_Result_Mask.tif");
	script = 
		"lw = WindowManager.getActiveWindow();\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(394,92);\n"+
		"}\n";
	eval("script", script);
	//waitForUser("Field" + " " + fieldnumber, "      eval 4");
	run("Red");

	selectWindow("" + samplename + "_field_" + fieldnumber + "_LY_Count_Result_Mask.tif");

	////waitForUser("Field" + " " + fieldnumber, "      eval 5");
	run("Blue");
	
	selectWindow("" + samplename + "_field_" + fieldnumber + ".tif");
	script = 
		"lw = WindowManager.getActiveWindow();\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(394,92);\n"+
		"}\n";
	eval("script", script);
	//waitForUser("Field" + " " + fieldnumber, "      eval 6"); 
	imageCalculator("Add create", "" + samplename + "_field_" + fieldnumber + ".tif","" + samplename + "_field_" + fieldnumber + "_DY_Count_Result_Mask.tif");
	
	selectWindow("Result of " + samplename + "_field_" + fieldnumber + ".tif");
	run("Set... ", "zoom=50 x=944 y=944");

	script = 
		"lw = WindowManager.getWindow('Result of " + samplename + "_field_" + fieldnumber + ".tif');\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(394,92);\n"+
		"}\n";
	eval("script", script);
	//waitForUser("Field" + " " + fieldnumber, "      eval 7");
	
	imageCalculator("Add create", "Result of " + samplename + "_field_" + fieldnumber + ".tif","" + samplename + "_field_" + fieldnumber + "_LY_Count_Result_Mask.tif");

	selectWindow("Result of Result of " + samplename + "_field_" + fieldnumber + ".tif");
	run("Set... ", "zoom=50 x=944 y=944");
	script = 
		"lw = WindowManager.getActiveWindow();\n"+
		"if (lw!=null) {\n"+
		"   lw.setLocation(1337,92);\n"+
		"}\n";
	eval("script", script);
	
	
	// Show the original image on the left
	selectWindow(samplename + "_field_" + fieldnumber + ".tif");
	
	waitForUser("Field" + " " + fieldnumber, "      How did we do?");
	
	run("Close All");

}

run("Quit");