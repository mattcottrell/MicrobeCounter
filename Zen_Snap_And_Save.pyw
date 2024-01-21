#! python

import sys
import win32com.client
Zen = win32com.client.GetActiveObject("Zeiss.Micro.Scripting.ZenWrapperLM")


thePath = str(sys.argv[1])
theFileName = str(sys.argv[2])

print("thePath =", thePath)

image = Zen.Acquisition.AcquireImage()
#Zen.Application.Save(image, "C:\\Users\\Cottrell\\Pictures\\Test11\\" + theFileName, False)
Zen.Application.Save(image, thePath + "\\" + theFileName, False)
#Zen.Acquisition.StopLive()
