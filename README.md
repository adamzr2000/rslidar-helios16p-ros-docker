# 3D LiDAR ROS Drivers. 

## What is it?


## What does this container do?

This container runs the ROS drivers for the RS-Helios-16P 3D LiDAR - RoboSense.

## Run it?

### Dependencies:

The 3D LiDAR ROS Drivers depends on:
  - ros-master (tutorial [here](../ros-master/))

### First you will need to build the container. 

In order to do that, run the following script:
```bash
./build.sh
```

### This will build the `3d-lidar` docker image. 

Verify that the image is present by running:
```bash
docker image ls
```

### Docker run example
In this folder we also provide a docker run example. 

> Note: ensure that the 3D LiDAR is connected via Ethernet to your PC before testing this container.

To run the 3D LiDAR ROS Drivers:
```bash
./run_example.sh
```

Verify that the container is up and running:
```bash
docker ps
```

In the output you should be able to see the `3d-lidar` container up and running.

Execute inside the container:
```bash
roslaunch rslidar_sdk start.launch
```




