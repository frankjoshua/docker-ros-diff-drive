FROM ros:noetic-ros-base

RUN apt update &&\
  apt install -y python3 python3-pip git ros-$ROS_DISTRO-tf &&\
  apt -y clean &&\
  apt -y purge &&\
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN python3 -m pip install pyyaml

RUN /bin/bash -c "source /opt/ros/$ROS_DISTRO/setup.bash" &&\
  mkdir -p ~/catkin_ws/src &&\
  cd ~/catkin_ws/src &&\
  git clone https://github.com/frankjoshua/differential-drive &&\
  cd ~/catkin_ws &&\
  /bin/bash -c "source /opt/ros/$ROS_DISTRO/setup.bash && catkin_make install"

RUN chmod a+x /root/catkin_ws/src/differential-drive/scripts/*.py

ENV ROS_NODE=diff_drive

HEALTHCHECK CMD /ros_entrypoint.sh rosnode info $ROS_NODE || exit 1

COPY ./ros_entrypoint.sh /
COPY ./ros.launch /
CMD ["roslaunch", "--wait", "ros.launch"]