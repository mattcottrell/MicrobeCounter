from __future__ import print_function

import cv2 as cv
import sys
import numpy as np
import random as rng
import time
import win32gui
import os

toolbar_width = 80

thepath = str(sys.argv[1])
theFileName = str(sys.argv[2])

ddepth = cv.CV_8U

src = cv.imread(thepath + "\\" + theFileName)

resize = cv.resize(src,(924, 771))
cv.imshow("Original Image", resize)
cv.moveWindow("Original Image",0,0)
#cv.waitKey(1000)

# Convert to grey scale
img = cv.cvtColor(src,  cv.COLOR_RGBA2GRAY, 0)

# output image with contours
img_copy = img.copy()

img_out = np.zeros((2056, 2464, 3), dtype = "uint8")

# Blur the image for better edge detection
img_blur = cv.GaussianBlur(img, (3,3), cv.BORDER_DEFAULT)

# Blur the upper left corner to remove objects
# that might interfer with the flood filling

# Create ROI coordinates
topLeft = (0, 0)
bottomRight = (200, 200)
x, y = topLeft[0], topLeft[1]
w, h = bottomRight[0] - topLeft[0], bottomRight[1] - topLeft[1]

# Grab ROI with Numpy slicing and blur
ROI = img_blur[y:y+h, x:x+w]
#blur = cv.GaussianBlur(ROI, (5,5), cv.BORDER_DEFAULT) 
blur = cv.blur(ROI, (50,50), cv.BORDER_DEFAULT)

# Insert ROI back into image
img_blur[y:y+h, x:x+w] = blur
#img_blur[y:y+h, x:x+w] = 100

#Show the result
resize = cv.resize(img_blur,(924, 771))
cv.imshow("Gaussian Blur", resize)
cv.moveWindow("Gaussian Blur",0,0)

####### Detect the dead cells using a simple threshold ##########

# Invertt the image
im_in = img_blur

resize = cv.resize(im_in,(924, 771))
cv.imshow("Image im_in", resize)
cv.moveWindow("Image im_in",0,0)

# Threshold.
# Set values equal to or above 220 to 0.
# Set values below 220 to 255.
#th, im_th = cv.threshold(im_in, 220, 255, cv.THRESH_BINARY_INV)
th, im_th = cv.threshold(im_in, 100, 255, cv.THRESH_BINARY)
#th, im_th = cv.threshold(im_in, 80, 255, cv.THRESH_BINARY)

resize = cv.resize(im_th,(924, 771))
cv.imshow("Thresholded Image", resize)
cv.moveWindow("Thresholded Image",0,0)
#cv.imshow("Thresholded Image", im_th)
#cv.waitKey(0)

# Image directory
directory = thepath

# Change the current directory 
# to specified directory 
os.chdir(directory)

# Using cv2.imwrite() method
# Saving the image
cv.imwrite("Image im_in.tif", im_in)
#cv.imwrite("Inverted and Blured.tif", invert_blur)

# Copy the thresholded image.
im_floodfill = im_th.copy()

# Dilate a bit the image
kernel1 = np.ones((3,3), dtype=np.uint8)
im_floodfill = cv.dilate(im_floodfill, kernel1)

# Dilate the flood filled image to make gaps in the live cell  perimeters

# Mask used to flood filling.
# Notice the size needs to be 2 pixels than the image.
h, w = im_th.shape[:2]
mask = np.zeros((h+2, w+2), np.uint8)

# Floodfill from point (0, 0)
cv.floodFill(im_floodfill, mask, (0,0), 255);

# Invert floodfilled image
# This shows the dead cells, but must remove noise
im_floodfill_inv = cv.bitwise_not(im_floodfill)

# noise removal
kernel = np.ones((5,5),np.uint8)
opening = cv.morphologyEx(im_floodfill_inv,cv.MORPH_OPEN,kernel, iterations = 1)

# The image after opening has oval dead cell and some remaining noise.

# Combine the two images to get the foreground.
#im_out = im_th | im_floodfill_inv

# Display images.
#resize = cv.resize(im_th,(924, 771))
#cv.imshow("Thresholded Image", resize)
resize = cv.resize(im_floodfill,(924, 771))
cv.imshow("Floodfilled Image", resize)
cv.moveWindow("Floodfilled Image",0,0)

resize = cv.resize(im_floodfill_inv,(924, 771))
cv.imshow("Inverted Floodfilled Image", resize)
cv.moveWindow("Inverted Floodfilled Image",0,0)

resize = cv.resize(opening,(924, 771))
cv.imshow("Opening", resize)
cv.moveWindow("Opening",0,0)

cv.waitKey(0)

# Find elipses
# https://www.geeksforgeeks.org/find-circles-and-ellipses-in-an-image-using-opencv-python/

# Load image
#image = cv.imread('C://gfg//images//blobs.jpg', 0)

# Set our filtering parameters
# Initialize parameter settiing using cv.SimpleBlobDetector
params = cv.SimpleBlobDetector_Params()

# Set Area filtering parameters
params.filterByArea = True
#params.minArea = 1500
params.minArea = 1250

# Set Circularity filtering parameters
params.filterByCircularity = True
params.minCircularity = 0.5
#params.minCircularity = 0.6

# Set Convexity filtering parameters
params.filterByConvexity = False
params.minConvexity = 0.2

# Set inertia filtering parameters
params.filterByInertia = False
params.minInertiaRatio = 0.01

# Create a detector with the parameters
detector = cv.SimpleBlobDetector_create(params)

# Invert opened image
opening_inv = cv.bitwise_not(opening)

resize = cv.resize(opening_inv,(924, 771))
cv.imshow("opening_inv", resize)
cv.moveWindow("opening_inv",0,0)

# Detect blobs
keypoints = detector.detect(opening_inv)

# Draw red circles corresponding to the blobs in the original image
for x in range(1,len(keypoints)):
	blobs=cv.circle(src, (int(keypoints[x].pt[0]),int(keypoints[x].pt[1])), radius=round(0.2*(int(keypoints[x].size))), color=(0,0,255), thickness=-1)

number_of_blobs = len(keypoints)
text = "Dead yeast cell count = " + str(len(keypoints))
cv.putText(blobs, text, (20, 2000),cv.FONT_HERSHEY_SIMPLEX, 3, (255, 255, 255), 10)

#print(str(len(keypoints)) + " ")

dead_cell_count = str(len(keypoints))

# Show blobs
#cv.imshow("Yeast Counter", blobs)

# Zoom out
#resize = cv.resize(blobs,(1232, 1028))
resize_dead = cv.resize(blobs,(924, 771))
cv.imshow("Dead Yeast Blobs", resize_dead)
cv.moveWindow("Dead Yeast Blobs",0,0)

################### End dead cells ############################

#edges = cv.Canny(image=img_blur, threshold1=1, threshold2=100)
lap = cv.Laplacian(img_blur, ddepth, ksize=5)

#Show result
#resize = image_resize(lap, height = 800)
resize = cv.resize(lap,(924, 771))
cv.imshow("Laplacian", resize)
cv.moveWindow("Laplacian",0,0)
#cv.waitKey(1)
#cv.destroyAllWindows()

# Blur the image for better edge detection
img_blur = cv.GaussianBlur(lap, (3,3), cv.BORDER_DEFAULT)

ret, thresh = cv.threshold(img_blur,127,255,cv.THRESH_BINARY)

resize = cv.resize(thresh,(924, 771))
cv.imshow("Threshold", resize)
cv.moveWindow("Threshold",0,0)
# cv.waitKey(1)
# cv.destroyAllWindows()

# Blur the image for better edge detection
#img_blur = cv.GaussianBlur(laplacian.astype('float32'), (3,3), cv.BORDER_DEFAULT)
#canny_edges = cv.Canny(image=gry, threshold1=1, threshold2=100)

# noise removal
# kernel = np.ones((3,3),np.uint8)
# opening = cv.morphologyEx(thresh,cv.MORPH_OPEN,kernel, iterations = 1)
#
# # cv.imshow("Opening Noise Reduction", opening)
# # cv.waitKey(1)
# # cv.destroyAllWindows()
#
# filling
# kernel = np.ones((6,6),np.uint8)
# closing = cv.morphologyEx(thresh,cv.MORPH_CLOSE,kernel, iterations = 3)
#
# # cv.imshow("Filling by closing", closing)
# # cv.waitKey(1)
# # cv.destroyAllWindows()

# Cross-shaped kernel (structuring element)
cv.getStructuringElement(cv.MORPH_RECT,(5,5))
kernel = np.array ([[1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1],
	[1, 1, 1, 1, 1]], dtype = np.uint8)

# dilation
dlt = cv.dilate(thresh, kernel, iterations=1)
#dlt = thresh

#Show result
resize = cv.resize(dlt,(924, 771))
cv.imshow("Dilate", resize)
cv.moveWindow("Dilate",0,0)
# cv.waitKey(1)
# cv.destroyAllWindows()

# Copy the image
im_floodfill = dlt.copy()

# Mask used to flood filling.
# Notice the size needs to be 2 pixels than the image.
h, w = dlt.shape[:2]
mask = np.zeros((h+2, w+2), np.uint8)

# Floodfill from point (0, 0)
cv.floodFill(im_floodfill, mask, (0,0), 255);

# Invert floodfilled image
im_floodfill_inv = cv.bitwise_not(im_floodfill)

# Combine the two images to get the foreground.
img_out = dlt | im_floodfill_inv

# Invert img_out
#img_out_inv = cv.bitwise_not(img_out)

# Display images.
#resize = image_resize(img_out, height = 800)
resize = cv.resize(img_out,(924, 771))
cv.imshow("Flood Filled", resize)
cv.moveWindow("Flood Filled",0,0)
# cv.waitKey(1)
# cv.destroyAllWindows()

# noise removal
kernel = np.ones((3,3),np.uint8)
opening = cv.morphologyEx(img_out,cv.MORPH_OPEN,kernel, iterations = 6)

# Display images.

#resize = image_resize(opening, height = 800)
resize = cv.resize(opening,(924, 771))
cv.imshow("Opened to Remove Noise", resize)
cv.moveWindow("Opened to Remove Noise",0,0)
# cv.waitKey(1)
# cv.destroyAllWindows()

# sure background area
kernel = np.ones((3,3),np.uint8)
sure_bg = cv.dilate(opening,kernel,iterations=3)

# Show the result
#resize = image_resize(sure_bg, height = 800)
resize = cv.resize(sure_bg,(924, 771))
cv.imshow("Sure Background", resize)
cv.moveWindow("Sure Background",0,0)
# cv.waitKey(1)
# cv.destroyAllWindows()

# Finding sure foreground area
dist_transform = cv.distanceTransform(opening,cv.DIST_L2,5)
#dist_transform = cv.distanceTransform(opening,cv.DIST_L2,5)
#dist_transform = cv.distanceTransform(opening,cv.DIST_L1,5)
#dist_transform = cv.distanceTransform(opening,cv.DIST_C,5)

cv.normalize(dist_transform, dist_transform, 0, 1.0, cv.NORM_MINMAX)

# Show the result
#resize = image_resize(dist_transform, height = 800)
resize = cv.resize(dist_transform,(924, 771))
cv.imshow("Distance Transform", resize)
cv.moveWindow("Distance Transform",0,0)
# cv.waitKey(1)
# cv.destroyAllWindows()

# Threshold to obtain the peaks
# This will be the markers for the foreground objects
#_, dist = cv.threshold(dist_transform, 0.4, 1.0, cv.THRESH_BINARY)
_, dist = cv.threshold(dist_transform, 0.35, 1.0, cv.THRESH_BINARY)

# Dilate a bit the dist image
kernel1 = np.ones((3,3), dtype=np.uint8)
dist = cv.dilate(dist, kernel1)

# Show the results
#resize = image_resize(dist, height = 800)
resize = cv.resize(dist,(924, 771))
cv.imshow("Peaks Sure Forground", resize)
cv.moveWindow("Peaks Sure Forground",0,0)
# cv.waitKey(1)
# cv.destroyAllWindows()

######################################
# Maybe draw dead blobs here on dist in black
######################################

# Draw bllack circles corresponding to the dead cells to erase those from the sure forground
for x in range(1,len(keypoints)):
	erase_dead_cells=cv.circle(dist, (int(keypoints[x].pt[0]),int(keypoints[x].pt[1])), radius=round(0.4*(int(keypoints[x].size))), color=(0,0,0), thickness=-1)

# noise removal
kernel = np.ones((3,3),np.uint8)
erase_dead_cells = cv.morphologyEx(erase_dead_cells,cv.MORPH_OPEN,kernel, iterations = 6)

resize = cv.resize(erase_dead_cells,(924, 771))
cv.imshow("Dead Cells Erased", resize)
cv.moveWindow("Dead Cells Erased",0,0)

# Create the CV_8U version of the distance image
# It is needed for findContours()
#dist_8u = dist.astype('uint8')
dist_8u = erase_dead_cells.astype('uint8')

# Find total markers
contours, _ = cv.findContours(dist_8u, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE)

# Create the marker image for the watershed algorithm
markers = np.zeros(dist.shape, dtype=np.int32)

# Draw the foreground markers
for i in range(len(contours)):
	cv.drawContours(markers, contours, i, (i+1), -1)

# Draw the background marker
cv.circle(markers, (5,5), 3, (255,255,255), -1)
markers_8u = (markers * 10).astype('uint8')

# Show the result
resize = cv.resize(markers_8u,(924, 771))
cv.imshow("Markers", resize)
cv.moveWindow("Markers",0,0)
# cv.waitKey(1)
# cv.destroyAllWindows()

## This could be difficult
sharp = np.float32(src)
#imgResult = sharp - imgLaplacian
#imgResult = sharp - lap
imgResult = img - lap
# convert back to 8bits gray scale
#imgResult = np.clip(imgResult, 0, 255)
#imgResult = imgResult.astype('uint8')

# Perform the watershed algorithm
#cv.watershed(imgResult, markers)
cv.watershed(src, markers)
#mark = np.zeros(markers.shape, dtype=np.uint8)
mark = markers.astype('uint8')
mark = cv.bitwise_not(mark)

# uncomment this if you want to see how the mark
# image looks like at that point
## cv.imshow('Markers_v2', mark)

########## Long Process ##############

# setup toolbar
# sys.stdout.write("[%s]" % (" " * toolbar_width))
# sys.stdout.flush()
# sys.stdout.write("\b" * (toolbar_width+1)) # return to start of line, after '['

# for i in range(toolbar_width):
# 	#time.sleep(0.1) # do real work here
# 	# Show the result
# 	# cv.imshow('Markers_v2', mark)
# 	# cv.waitKey(1)
# 	# cv.destroyAllWindows()
# 	# update the bar
# 	sys.stdout.write("-")
# 	sys.stdout.flush()
# 	if i == 40:
# 		for j in range(toolbar_width):
# 			sys.stdout.write("\b \b")

# sys.stdout.write("]\n") # this ends the progress bar

##########    End      ###############

# Generate random colors
rng.seed(12345)
colors = []
for contour in contours:
	colors.append((rng.randint(0,256), rng.randint(0,256), rng.randint(0,256)))

# Create the result image
dst = np.zeros((markers.shape[0], markers.shape[1], 3), dtype=np.uint8)

# Fill labeled objects with random colors
for i in range(markers.shape[0]):
	for j in range(markers.shape[1]):
		index = markers[i,j]
		if index > 0 and index <= len(contours):
			dst[i,j,:] = colors[index-1]

alpha = 0.3

# try:
#     raw_input          # Python 2
# except NameError:
#     raw_input = input  # Python 3
#
# print(''' Simple Linear Blender
# -----------------------
# * Enter alpha [0.0-1.0]: ''')
#
# input_alpha = float(raw_input().strip())
#
# if 0 <= alpha <= 1:
#     alpha = input_alpha

# [load]
src1 = dst
src2 = src
# [load]
if src1 is None:
	print("Error loading src1")
	exit(-1)
elif src2 is None:
	print("Error loading src2")
	exit(-1)
# [blend_images]
beta = (1.0 - alpha)
dst = cv.addWeighted(src1, alpha, src2, beta, 0.0)
# [blend_images]

# Print the cell count
cellCount = len(contours)
#print(len(contours))

print(str(cellCount) + " " + str(dead_cell_count))

# Show the final image
resize = cv.resize(dst,(924, 771))
cv.imshow('Field ' + theFileName + "                                                                              " + "Cell count =" + " " + str(cellCount), resize)
cv.moveWindow('Field ' + theFileName + "                                                                              " + "Cell count =" + " " + str(cellCount), 0,0)

#hwnd = win32gui.FindWindow(None, "C:\Windows\py.exe")
#win32gui.MoveWindow(hwnd, 1000, 0, 200, 100, True)

# Image directory
directory = thepath

# Change the current directory 
# to specified directory 
os.chdir(directory)

# Using cv2.imwrite() method
# Saving the image
cv.imwrite("Final" + "_" + theFileName, resize)

#cv.waitKey(0)

#cv.destroyAllWindows()



