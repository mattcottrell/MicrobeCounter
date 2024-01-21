#! python

import win32com.client
Zen = win32com.client.GetActiveObject("Zeiss.Micro.Scripting.ZenWrapperLM")

# Set the hardware settings
hardwareSetting = Zen.ObjectFactory.Create("Zeiss.Micro.Scripting.ZenHardwareSetting")
hardwareSetting.Load("40X Objective",0)
Zen.Devices.ApplyHardwareSetting(hardwareSetting)

#Set the camera settings
#camerasetting = Zen.Acquisition.CameraSettings.GetByName("Live Dead MV Yeast Hemocytometer.czcs")
camerasetting = Zen.Acquisition.CameraSettings.GetByName("250 um 40X Objective.czcs")
Zen.Acquisition.ActiveCamera.ApplyCameraSetting(camerasetting)

