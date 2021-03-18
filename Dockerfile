FROM ros:noetic

RUN sudo apt-get -y update

# fixes prompts during apt installations
RUN echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections
RUN sudo apt-get install -y -q

# create the user "mrs" and add it to sudoers, so it can go on with the installation
RUN useradd -m mrs && echo "mrs:mrs" | chpasswd && adduser mrs sudo
RUN echo "mrs ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/mrs
RUN chmod 0440 /etc/sudoers.d/mrs
USER mrs
ENV HOME /home/mrs

# refresh apt, install git
RUN sudo apt-get -y update && sudo apt-get -y install git

# clone the mrs_uav_system
RUN mkdir ~/git && cd ~/git && git clone https://github.com/ctu-mrs/mrs_uav_system

# install the mrs_uav_system
RUN cd ~/git/mrs_uav_system && ./install.sh

# install some basic utilities so the image is somewhat usable
RUN sudo apt-get -y install vim ranger

CMD ["bash"]
