#!/bin/bash

#  BuildScript.command
#  BluBolt Converter
#  Created by Jay Sharma
#  Copyright © 2018 Jay Sharma. All rights reserved.

date
echo "Build Started"
echo "Beginning Build Process"
echo "Initating FFmpeg"

$1
#/usr/local/bin/ffmpeg -i inputURL.y4m -c:v encoder outputURL.container

echo "Terminating build..."
echo "Removing Cocoa framework references..."
date
echo "\"Video Converter Suite using Cocoa Framework\""
echo "Project by Jay Sharma, A2305214054, 8CSE1"

