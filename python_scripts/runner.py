import re
from urllib.request import urlopen
import cv2
import cvlib as cv
import collections
import subprocess
from cvlib.object_detection import draw_bbox
import os
import json
import time


def find_segments(string):
    segments = re.findall('segment-\d*\.ts', string)
    return segments


def load_url(url):
    f = urlopen(url)
    return f.read().decode("utf-8")


def load_ts_segments(url):
    html = load_url(url)

    playlist_url = re.findall('(https?://.*\.m3u8\?token=.*)\'', html)[0]
    print("found playlist_url = ", playlist_url)

    base = "/".join(playlist_url.split("/")[:-1])
    print("base = ", base)
    values = load_url(playlist_url)
    segments = find_segments(values)
    return base, segments


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


def process(file):
    filename = "../images/" + file + ".jpg"
    json_file_name = "../images/json/" + file + ".json"
    detected_file_name = "../images/detected/" + file + ".jpg"
    processed_file_name = "../images/processed/" + file + ".jpg"
    person_file_name = "../images/person/" + file + ".jpg"

    print("READING: " + filename)
    image = cv2.imread(filename)
    print("-- CROPPING")
    image = image[400:1440, 700:2300]
    print("-- DETECTING COMMON OBJECTS")
    boxes, labels, conf = cv.detect_common_objects(image, model="yolov3")

    data = {
        "person_found": False,
        "person_found_in_rectangle": False
    }

    for i in range(len(labels)):
        label = labels[i]
        if label == "person":
            data["person_found"] = True
            print("--- FOUND PERSON")
            cv2.imwrite(person_file_name, image)
            box = boxes[i]
            rect = Rectangle((box[0], box[1]), (box[2], box[3]))
            left = rect.overlaps(leftBox)
            right = rect.overlaps(rightBox)
            back = rect.overlaps(backBox)

            print("---- Checking leftBox", left)
            print("---- Checking rightBox", right)
            print("---- Checking backBox", back)

            if ((left and back) or (right and back)):
                print("----- PERSON IN THE RECTANGLE", conf[i])
                data["person_found_in_rectangle"] = True
                out = draw_bbox(image, [box], [label], [conf[i]])
                cv2.imwrite(detected_file_name, out)

    print("-- RENAMING " + filename + " TO " + processed_file_name)
    os.rename(filename, processed_file_name)

    data["labels"] = labels
    data["boxes"] = boxes

    print("-- WRITING " + json_file_name)
    with open(json_file_name, "w") as outfile:
        json.dump(data, outfile, sort_keys=True,
                  indent=4, separators=(',', ': '))


leftBox = Rectangle((703, 561), (1176, 1406))
rightBox = Rectangle((1778, 561), (2302, 1406))
backBox = Rectangle((703, 561), (2300, 920))
path_to_watch = "../images"
url = "https://v.angelcam.com/iframe?v=9klzdgn2y4"

while 1:
    base, segments = load_ts_segments(url)
    for segment in segments:
        segment_url = (base + "/" + segment)
        rc = subprocess.call("wget -q -nc -O ../videos/" +
                             segment + " " + segment_url, shell=True)
        if rc == 0:
            rc = subprocess.call("ffmpeg -hide_banner -loglevel panic -i ../videos/" +
                                 segment + " -vframes 1 -f image2 ../images/" + segment + ".jpg", shell=True)
            print(rc)
            rc = subprocess.call("b2 upload_file meatsweats ../videos/" +
                                 segment + " ../videos/" + segment, shell=True)
            print(rc)

    print("Sleeping for 30 seconds")
    time.sleep(5)
