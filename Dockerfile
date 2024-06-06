# Specify the ROS distribution as a build argument
ARG ROS_DISTRO=noetic
 
# Use an official ROS base image 
FROM osrf/ros:${ROS_DISTRO}-desktop-full

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics


# Label to indicate the maintainer of this Dockerfile
LABEL maintainer="azahir@pa.uc3m.es"

# Setup the working directory in the container
WORKDIR /root

# Create a new user with sudo privileges and set a password
RUN useradd -m 3d-lidar && \
    echo "3d-lidar:3d-lidar" | chpasswd && adduser 3d-lidar sudo

# Set an environment variable to noninteractive to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Use bash shell for subsequent commands
SHELL [ "/bin/bash", "-c" ]

# Install necessary packages and dependencies
RUN apt-get update && apt-get install -y \
    libyaml-cpp-dev \
    libpcap-dev \
    && rm -rf /var/lib/apt/lists/*


# Switch to the newly created user for better security (avoid using root)
USER 3d-lidar
WORKDIR /home/3d-lidar

# Clone the necessary ROS packages into the catkin workspace
RUN mkdir -p catkin_ws/src 
COPY catkin_ws/src /home/3d-lidar/catkin_ws/src

# Fix permissions
USER root
RUN chown -R 3d-lidar:3d-lidar /home/3d-lidar/catkin_ws
USER 3d-lidar

# Build the catkin workspace
RUN cd ~/catkin_ws && source /opt/ros/${ROS_DISTRO}/setup.bash && catkin_make 

# Add ROS environment setup to bashrc of user '3d-lidar'
RUN echo "source ~/catkin_ws/devel/setup.bash" >> ~/.bashrc
