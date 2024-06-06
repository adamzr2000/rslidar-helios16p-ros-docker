#!/bin/bash

# Assemble docker image. 
echo 'Building 3d-lidar docker image.'
sudo docker build . -t 3d-lidar
