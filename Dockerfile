#
# CannyOS User Storage Dropbox
#
# https://github.com/intlabs/cannyos-user-desktop-gnome
#
# Copyright 2014 Pete Birley
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Pull base image.
FROM intlabs/dockerfile-cannyos-ubuntu-14_04-fuse

# Set environment variables.
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

# Set the working directory
WORKDIR /

#****************************************************
#                                                   *
#         INSERT COMMANDS BELLOW THIS               *
#                                                   *
#****************************************************

#Allow remote root login with password
RUN sed -i -e 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config && /etc/init.d/ssh restart

# Install GNOME and tightvnc server.
RUN apt-get update && apt-get install -y xorg gnome-core gnome-session-fallback tightvncserver

# Pull in the hack to fix keyboard shortcut bindings for GNOME 3 under VNC
ADD CannyOS/Desktop/Gnome/gnome-keybindings.pl /CannyOS/Desktop/Gnome/gnome-keybindings.pl
RUN chmod +x /CannyOS/Desktop/Gnome/gnome-keybindings.pl

# Add the script to fix and customise GNOME for docker
ADD CannyOS/Desktop/Gnome/gnome-docker-fix-and-customise.sh /CannyOS/Desktop/Gnome/gnome-docker-fix-and-customise.sh
RUN chmod +x /CannyOS/Desktop/Gnome/gnome-docker-fix-and-customise.sh

# Set up VNC
RUN apt-get install -y expect
RUN mkdir -p /root/.vnc
ADD CannyOS/Desktop/X11/xstartup /root/.vnc/xstartup
RUN chmod 755 /root/.vnc/xstartup


#add the startup files to the user account
RUN mkdir -p /home/user/.vnc

ADD CannyOS/Desktop/X11/xstartup /home/user/.vnc/xstartup
RUN chmod 755 /home/user/.vnc/xstartup

#Add script to start vnc sever and set password - should be replaced with somthing much more elegant
ADD CannyOS/Desktop/Gnome/start-vnc-expect-script.sh /CannyOS/Desktop/Gnome/start-vnc-expect-script.sh
RUN chmod +x /CannyOS/Desktop/Gnome/start-vnc-expect-script.sh

#Add the tightvnc configuration file
ADD CannyOS/Desktop/VNC/vnc.conf /etc/vnc.conf

#Install noVNC
RUN apt-get install -y git python-numpy
WORKDIR /CannyOS/Desktop
RUN git clone git://github.com/kanaka/noVNC
RUN cp noVNC/vnc_auto.html noVNC/index.html

USER user

#****************************************************
#                                                   *
#         ONLY PORT RULES BELLOW THIS               *
#                                                   *
#****************************************************

#SSH
EXPOSE 22/tcp

#HTTP
EXPOSE 80/tcp

#****************************************************
#                                                   *
#         NO COMMANDS BELLOW THIS                   *
#                                                   *
#****************************************************

# Add startup 
ADD /CannyOS/startup.sh /CannyOS/startup.sh
RUN chmod +x /CannyOS/startup.sh

# Add post-install script
#ADD /CannyOS/post-install.sh /CannyOS/post-install.sh
#RUN chmod +x /CannyOS/post-install.sh

# Define default command.
ENTRYPOINT ["/CannyOS/startup.sh"]