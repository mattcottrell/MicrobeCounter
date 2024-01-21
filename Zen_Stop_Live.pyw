#! python

import win32com.client
Zen = win32com.client.GetActiveObject("Zeiss.Micro.Scripting.ZenWrapperLM")
Zen.Acquisition.StopLive()