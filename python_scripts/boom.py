# detect.py
import cv2
import cvlib as cv

img = cv2.imread("image2.png")
boxes, labels, _conf = cv.detect_common_objects(img, model="yolov3")

print(labels, boxes)
