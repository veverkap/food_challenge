import cv2
import cvlib as cv
import collections
from cvlib.object_detection import draw_bbox
import os
import json
import time


# path
path = "../images/processed/bigtexan_1579743045_00031.jpg"

# Reading an image in default mode
image = cv2.imread(path)

image = image[400:1440, 700:2300]
# cv2.imshow("cropped", crop_img)
# boxes, labels, conf = cv.detect_common_objects(image, model="yolov3")

# out = draw_bbox(crop_img, boxes, labels, conf)
# <map name = "image-map" >
# <area target = "" alt = "left" title = "left" href = "" coords = "44,160,464,1024" shape = "rect" >
# <area target = "" alt = "" title = "" href = "" coords = "1076,141,1535,976" shape = "0" >
# </map >

# # Draw a rectangle with blue line borders of thickness of 2 px
image = cv2.rectangle(image, (38, 160), (464, 1024), (0, 0, 255), 3)  # left
image = cv2.rectangle(image, (1150, 141), (1600, 976), (0, 0, 255), 3)  # right
# image = cv2.rectangle(image, (703, 561), (2300, 920), (0, 255, 0), 3)  # total


# print("writing " + detected_file_name)
cv2.imwrite("ohmy.png", image)

# image = cv2.rectangle(image, (1648, 334), (2030, 832), (0, 0, 0), 3)  # total
# image = cv2.rectangle(image, (330, 306), (790, 856), (0, 0, 0), 3)  # total

# [1648, 334, 2030, 832]
# [330, 306, 790, 856]
# image
# Displaying the image
