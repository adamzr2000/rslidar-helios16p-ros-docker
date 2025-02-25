xhost local:root

XAUTH=/tmp/.docker.xauth

# nvidia-container-runtime
export NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-all}
export NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics



# Function to validate IP address format
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to display the menu for ROS_MASTER_URI
display_menu_master() {
    echo "==============================="
    echo "      Select ROS_MASTER_URI    "
    echo "==============================="
    echo "  1 -> localhost"
    echo "  2 -> edge (192.168.40.4)"
    echo "  3 -> custom"
    echo "==============================="
}

# Function to display the menu for ROS_IP
display_menu_ip() {
    echo "==============================="
    echo "        Set ROS_IP             "
    echo "==============================="
    echo "  1 -> UE (192.168.40.70)"    
    echo "  2 -> edge (192.168.40.4)"
    echo "  3 -> custom"
    echo "==============================="
}

# Function to get user choice for ROS_MASTER_URI
get_choice_master() {
    read -p "Enter your choice for ROS_MASTER_URI (1/2/3): " choice_master
    case $choice_master in
        1) ros_master_uri="http://localhost:11311"; return;;
        2) ros_master_uri="http://192.168.40.4:11311"; return;;
        3) read -p "Enter custom ROS MASTER IP: " custom_uri;
            if validate_ip $custom_uri; then
                ros_master_uri="http://${custom_uri}:11311"; 
            else
                echo "Invalid IP address format. Please enter a valid IP address."
                get_choice_master
            fi
            return;;    
        *) echo "Invalid choice. Please enter 1, 2, or 3."; get_choice_master;;
    esac
}

# Function to get user choice for ROS_IP
get_choice_ip() {
    read -p "Enter your choice for ROS_IP (1/2/3): " choice_ip
    case $choice_ip in
        1) ros_ip="192.168.40.70"; return;;
        2) ros_ip="192.168.40.4"; return;;
        3) read -p "Enter custom ROS IP: " custom_ip; ros_ip="${custom_ip}";
            if validate_ip $custom_ip; then
                ros_ip="${custom_ip}"; 
            else
                echo "Invalid IP address format. Please enter a valid IP address."
                get_choice_ip
            fi
            return;;
        *) echo "Invalid choice. Please enter 1, 2, or 3."; get_choice_ip;;
    esac
}

# Prompt the user to select ROS MASTER URI
display_menu_master
get_choice_master

# If localhost selected, set ROS_IP to 127.0.0.1
if [[ $ros_master_uri == "http://localhost:11311" ]]; then
    ros_ip="127.0.0.1"
else
    # Prompt the user to select ROS_IP if ROS_MASTER_URI is not localhost
    display_menu_ip
    get_choice_ip
fi
echo "ROS_MASTER_URI: $ros_master_uri"
echo "ROS_IP: $ros_ip"

# Assemble docker image.
echo 'Running 3d-lidar docker image.'

# Directory on host to map to the container's catkin_ws directory
host_catkin_ws_dir="$(pwd)/catkin_ws/src"

docker run \
        -it \
        --name 3d-lidar \
        --hostname 3d-lidar \
        --rm \
        --net host \
        --privileged \
        -e ROS_MASTER_URI="$ros_master_uri" \
        -e ROS_IP="$ros_ip" \
        --env="DISPLAY=$DISPLAY" \
        --env="QT_X11_NO_MITSHM=1" \
        --env="QT_QPA_PLATFORM=xcb" \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        -v ${host_catkin_ws_dir}:/home/3d-lidar/catkin_ws/src \
        --env="XAUTHORITY=$XAUTH" \
        --volume="$XAUTH:$XAUTH" \
        --runtime=nvidia \
        3d-lidar:latest

echo "Done."