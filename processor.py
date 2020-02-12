from cvlib.object_detection import draw_bbox
import cv2
import cvlib as cv
import os
import json

from rectangle import Rectangle
from slacker import Slacker

leftBox = Rectangle((703, 561), (1176, 1406))
rightBox = Rectangle((1778, 561), (2302, 1406))
backBox = Rectangle((703, 561), (2300, 920))


class Processor:
    def __init__(self, filename):
        self.filename = filename
        self.json_file_name = filename.replace(
            "images/", "json/").replace(".jpg", ".json")
        self.detected_file_name = filename.replace(
            "images/", "images/detected/")
        self.processed_file_name = filename.replace(
            "images/", "images/processed/")
        self.person_file_name = filename.replace("images/", "images/person/")
        self.image_full = cv2.imread(filename)
        self.image = self.image_full[400:1440, 700:2300]
        self.data = {
            "person_found": False,
            "person_found_in_rectangle": False,
            "person_found_in_left_box": False,
            "person_found_in_right_box": False,
            "person_found_in_back_box": False,
        }

    def __repr__(self):
        return f"Processor for {self.filename} {str(self.data)}"

    def process(self):
        print("PROCESSING")
        boxes, labels, conf = cv.detect_common_objects(
            self.image, model="yolov3")

        self.data["labels"] = labels
        self.data["boxes"] = boxes

        for i in range(len(labels)):
            label = labels[i]
            if label == "person":
                confidence = conf[i]
                self.data["person_found"] = True
                print(f"--- FOUND PERSON with {confidence}")
                cv2.imwrite(self.person_file_name, self.image)
                box = boxes[i]
                rect = Rectangle((box[0], box[1]), (box[2], box[3]))

                left = rect.overlaps(leftBox)
                right = rect.overlaps(rightBox)
                back = rect.overlaps(backBox)

                self.data["person_found_in_left_box"] = left
                self.data["person_found_in_right_box"] = right
                self.data["person_found_in_back_box"] = back

                print("---- Checking leftBox", left)
                print("---- Checking rightBox", right)
                print("---- Checking backBox", back)

                if ((left and back) or (right and back)):
                    print("----- PERSON IN THE RECTANGLE", conf[i])
                    self.data["person_found_in_rectangle"] = True
                    out = draw_bbox(self.image, [box], [label], [conf[i]])
                    cv2.imwrite(self.detected_file_name, out)
                    Slacker.postToSlack(self.detected_file_name)
                    Slacker.postToTwitter(self.detected_file_name)

                    with open(self.json_file_name, "w") as outfile:
                        json.dump(self.data, outfile, sort_keys=True,
                                  indent=4, separators=(',', ': '))

                # print("-- RENAMING " + self.filename +
                #       " TO " + self.processed_file_name)

                # os.rename(self.filename, self.processed_file_name)
                # print("-- WRITING " + self.json_file_name)

        print("-- REMOVING " + self.filename)
        try:
            os.remove(self.filename)
        except:
            print("Error while deleting file ", self.filename)
