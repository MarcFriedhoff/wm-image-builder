FROM ubuntu:24.04

# built-in packages
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    supervisor sudo net-tools \
    dbus-x11 x11-utils alsa-utils \
    mesa-utils libgl1-mesa-dri \
    xvfb x11vnc \
    lxqt openbox \
    git wget curl python3 python3-pip \
    tini \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up noVNC and websockify
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# VNC password (change as needed)
RUN mkdir -p /root/.vnc && x11vnc -storepasswd 1234 /root/.vnc/passwd

# add postgres db
RUN apt-get update && apt-get install -y postgresql postgresql-contrib vim && \
    sudo -u postgres createuser --superuser root && \
    sudo -u postgres createdb root

RUN mkdir -p /opt/softwareag && chown root:root /opt/softwareag

COPY --from=INSTALL /opt/softwareag/ /opt/softwareag/

# Add custom scripts and supervisor config
ADD ./templates/designer/startup.sh /
ADD ./templates/designer/supervisord.conf /etc/supervisor/conf.d/
ADD ./templates/designer/xvfb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/xvfb.sh


WORKDIR /root
ENV SHELL=/bin/bash
ENV DISPLAY=:1

EXPOSE 6080

ENTRYPOINT ["/startup.sh"]
