import cv2
import cvlib as cv
import collections
from cvlib.object_detection import draw_bbox
import os
import json
import time
path_to_watch = "../images"
before = dict([(f, None) for f in os.listdir(path_to_watch)])


class Rectangle:
    def __init__(self, pt1, pt2):
        self.set_points(pt1, pt2)

    def set_points(self, pt1, pt2):
        (x1, y1) = pt1
        (x2, y2) = pt2
        self.left = min(x1, x2)
        self.top = min(y1, y2)
        self.right = max(x1, x2)
        self.bottom = max(y1, y2)

    def overlaps(self, other):
        """Return true if a rectangle overlaps this rectangle."""
        return (self.right > other.left and self.left < other.right and
                self.top < other.bottom and self.bottom > other.top)


leftBox = Rectangle((703, 561), (1176, 1406))
rightBox = Rectangle((1778, 561), (2302, 1406))
backBox = Rectangle((703, 561), (2300, 920))


def process(file):
    filename = "../images/" + file + ".jpg"
    json_file_name = "../images/json/" + file + ".json"
    detected_file_name = "../images/detected/" + file + ".jpg"
    processed_file_name = "../images/processed/" + file + ".jpg"

    print("reading " + filename)
    image = cv2.imread(filename)
    image = image[400:1440, 700:2300]
    boxes, labels, conf = cv.detect_common_objects(image, model="yolov3")

    for i in range(len(labels)):
        label = labels[i]
        if label == "person":
            print("Found person")
            box = boxes[i]
            rect = Rectangle((box[0], box[1]), (box[2], box[3]))
            print("Checking leftBox")
            print(rect.overlaps(leftBox))
            print("Checking rightBox")
            print(rect.overlaps(rightBox))
            print("Checking backBox")
            print(rect.overlaps(backBox))
            print(boxes[i])
            print(conf[i])

    print(boxes)
    print(labels)
    print(conf)

    # out = draw_bbox(image, boxes, labels, conf)
    # print("writing " + detected_file_name)
    # cv2.imwrite(detected_file_name, out)
    # data = {}
    # data["labels"] = labels
    # data["boxes"] = boxes

    # print("writing " + json_file_name)
    # with open(json_file_name, "w") as outfile:
    #     json.dump(data, outfile)

    # print("renaming " + filename + " to " + processed_file_name)
    # os.rename(filename, processed_file_name)


# while 1:
#     time.sleep(5)
#     after = dict([(f, None) for f in os.listdir(path_to_watch)])
#     added = [f for f in after if not f in before]

#     if len(added) > 0:
#         filename = os.path.splitext(added[0])[0]
#         print("PROCESSING " + filename)
#         process(filename)

#     before = after

process("bigtexan_1579743045_00031")
