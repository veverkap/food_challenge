from cvlib.object_detection import draw_bbox
from rectangle import Rectangle

import cv2
import cvlib as cv
import io
import mimetypes
import numpy as np
import os
import uuid

leftBox = Rectangle((703, 561), (1176, 1406))
rightBox = Rectangle((1778, 561), (2302, 1406))
backBox = Rectangle((703, 561), (2300, 920))


class DetectingResource:

    def detect(self, input_image):
        file_bytes = np.asarray(
            bytearray(input_image.file.read()), dtype=np.uint8)
        image_full = cv2.imdecode(file_bytes, 1)

        image = image_full[400:1440, 700:2300]

        boxes, labels, confidences = cv.detect_common_objects(
            image, model="yolov3")

        person_found_in_left_box = False
        person_found_in_right_box = False
        person_found_in_back_box = False
        person_found_in_rectangle = False

        data = []
        for i in range(len(labels)):
            label = labels[i]
            box = boxes[i]
            confidence = confidences[i]
            item = {
                "label": {
                    "name": label,
                    "box": box,
                    "confidence": confidence
                },
                "person_found": False,
                "person_found_in_left_box": False,
                "person_found_in_right_box": False,
                "person_found_in_back_box": False,
                "person_found_in_rectangle": False
            }

            if label == "person":
                item["person_found"] = True
                rect = Rectangle((box[0], box[1]), (box[2], box[3]))

                left = rect.overlaps(leftBox)
                right = rect.overlaps(rightBox)
                back = rect.overlaps(backBox)

                if left:
                    person_found_in_left_box = True
                    item["person_found_in_left_box"] = True
                if right:
                    person_found_in_right_box = True
                    item["person_found_in_right_box"] = True
                if back:
                    person_found_in_back_box = True
                    item["person_found_in_back_box"] = True

                if ((left and back) or (right and back)):
                    person_found_in_rectangle = True
                    item["person_found_in_rectangle"] = True
            data.append(item)

        results = {
            "filename": input_image.filename,
            "content_type": input_image.content_type,
            "person_found_in_left_box": person_found_in_left_box,
            "person_found_in_right_box": person_found_in_right_box,
            "person_found_in_back_box": person_found_in_back_box,
            "person_found_in_rectangle": person_found_in_rectangle,
            "data": data
        }
        return results
