import cv2
import cvlib as cv
import os
import time
path_to_watch = "../images"
before = dict([(f, None) for f in os.listdir(path_to_watch)])


def process(file):
    img = cv2.imread("image2.png")
    boxes, labels, _conf = cv.detect_common_objects(img, model="yolov3")
    print(labels, boxes)


while 1:
    time.sleep(10)
    after = dict([(f, None) for f in os.listdir(path_to_watch)])
    added = [f for f in after if not f in before]
    removed = [f for f in before if not f in after]
    if added:
        print(added)
    if removed:
        print(removed)
    before = after
    print(len(added))
    if len(added) > 0:
        print("PROCESSING " + added[0])
        process(added[0])
