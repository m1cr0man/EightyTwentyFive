# OpenCV
from os.path import join as j
from copy import copy
import json, sys, os, re

def Slugify(raw_string):
    return re.sub(r'[^\w -._()]+', '', raw_string)[:249]

# Gets the path from the folder_map and parentId
def GetPath(elems, parentId, path=''):
    if int(parentId) <= 3:
        return j(path, elems[parentId])
    if parentId not in elems:
        raise IndexError('Invalid parent ' + parentId)
    parent = elems[parentId]
    return GetPath(elems, parent['parentId'], j(Slugify(parent['title']), path))

# Returns dictionary of bookmarks + hierarchy
def ReadJSONBookmarks(path):
    raw_data = []
    with open(path, 'r') as fhandle:
        raw_data = json.load(fhandle)

    data = {'1': '.', '2': 'Other Bookmarks', '3': 'Other Bookmarks'}

    # One iteration to index values
    # Another to build paths
    for val in raw_data:
        if val['id'] in data:
            raise IndexError('Duplicate ID ' + val['id'])
        data[val['id']] = val

    # Build the paths
    for (key, val) in data.items():
        if int(key) <= 3:
            continue
        val['path'] = GetPath(data, val['parentId'])

    # Remove the root elements
    del data['1']
    del data['2']
    del data['3']
    return data

def main():
    if len(sys.argv) < 2:
        return print("Not enough elements")
    data = ReadJSONBookmarks(sys.argv[1])

    # Make the root folder
    if not os.path.exists(sys.argv[2]):
        os.mkdir(sys.argv[2])
    os.chdir(sys.argv[2])

    for val in data.values():
        if not os.path.exists(val['path']):
            os.makedirs(val['path'])
        if 'url' not in val:
            print('Skipping folder', val['id'])
            continue
        with open(j(val['path'], Slugify(val['title'] or val['url']) + '.url'), 'w') as out_file:
            output_val = copy(val)
            del output_val['path']
            json.dump(output_val, out_file)
main()
