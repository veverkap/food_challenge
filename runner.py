from cvlib.object_detection import draw_bbox
from urllib.request import urlopen
import collections
import cv2
import cvlib as cv
import json
import os
import re
import subprocess
import time
from rectangle import Rectangle


def backup_all_things():
    print("Backing up videos")
    # for file in os.listdir(videos_folder):
    #     full_file = videos_folder + file
    #     print(" - backing up ", full_file)
    #     rc = subprocess.call("b2 upload_file meatsweats " +
    #                          full_file + " videos/" + file, shell=True)
    #     print(" - deleting ", full_file)
    #     os.remove(full_file)

    print("Backing up person images")
    person_folder = images_folder + "person/"
    for file in os.listdir(person_folder):
        full_file = person_folder + file
        print(" - backing up ", full_file)
        rc = subprocess.call("b2 upload_file meatsweats " +
                             full_file + " images/person/" + file, shell=True)
        print(" - deleting ", full_file)
        os.remove(full_file)

    print("Backing up detected images")
    detected_folder = images_folder + "detected/"
    for file in os.listdir(detected_folder):
        full_file = detected_folder + file
        print(" - backing up ", full_file)
        # rc = subprocess.call("b2 upload_file meatsweats " +
        #                      full_file + " videos/" + file, shell=True)
        # print(" - deleting ", full_file)
        # os.remove(full_file)


def backup_video(local_url, segment):

    return rc


def download_url(source, destination):
    print("Downloading ", source, " to ", destination)
    rc = subprocess.call("wget -q -nc -O " +
                         destination + " " + source, shell=True)
    return rc


def snapshot_video(video_url):
    image_url = video_url.replace(
        videos_folder, images_folder).replace(".ts", ".jpg")
    rc = subprocess.call("ffmpeg -hide_banner -loglevel panic -i " +
                         video_url + " -vframes 1 -f image2 " + image_url, shell=True)
    return image_url


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


def process(filename):
    json_file_name = filename.replace(
        "images/", "json/").replace(".jpg", ".json")
    detected_file_name = filename.replace("images/", "images/detected/")
    processed_file_name = filename.replace("images/", "images/processed/")
    person_file_name = filename.replace("images/", "images/person/")

    print("READING: " + filename)
    image = cv2.imread(filename)
    print("-- CROPPING")
    image = image[400:1440, 700:2300]
    print("-- DETECTING COMMON OBJECTS")
    boxes, labels, conf = cv.detect_common_objects(image, model="yolov3")

    data = {
        "person_found": False,
        "person_found_in_rectangle": False,
        "person_found_in_left_box": False,
        "person_found_in_right_box": False,
        "person_found_in_back_box": False,
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

            data["person_found_in_left_box"] = left
            data["person_found_in_right_box"] = right
            data["person_found_in_back_box"] = back

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

videos_folder = "./videos/"
images_folder = "./images/"

url = "https://v.angelcam.com/iframe?v=9klzdgn2y4"

backup_all_things()
# while 1:
# backup_all_things()
# base, segments = load_ts_segments(url)
# for segment in segments:
#     remote_url = (base + "/" + segment)
#     print("Loading TS Segment ", remote_url)
#     video_url = videos_folder + segment

#     if download_url(remote_url, video_url) == 0:
#         print("Processing file")
#         image_url = snapshot_video(video_url)
#         process(image_url)

# print("Sleeping for 30 seconds")
# time.sleep(5)
