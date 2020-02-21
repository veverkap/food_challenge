

# def backup_all_things():
# print("Backing up videos")
# for file in os.listdir(videos_folder):
#     full_file = videos_folder + file
#     print(" - backing up ", full_file)
#     rc = subprocess.call("b2 upload_file meatsweats " +
#                          full_file + " videos/" + file, shell=True)
#     print(" - deleting ", full_file)
#     os.remove(full_file)

# print("Backing up person images")
# person_folder = images_folder + "person/"
# for file in os.listdir(person_folder):
#     full_file = person_folder + file
#     print(" - backing up ", full_file)
#     rc = subprocess.call("b2 upload_file meatsweats " +
#                          full_file + " images/person/" + file, shell=True)
#     print(" - deleting ", full_file)
#     os.remove(full_file)

# print("Backing up detected images")
# detected_folder = images_folder + "detected/"
# for file in os.listdir(detected_folder):
#     full_file = detected_folder + file
#     print(" - backing up ", full_file)
# rc = subprocess.call("b2 upload_file meatsweats " +
#                      full_file + " videos/" + file, shell=True)
# print(" - deleting ", full_file)
# os.remove(full_file)
