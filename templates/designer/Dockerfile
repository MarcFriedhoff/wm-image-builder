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

# Install Firefox Browser firefox-esr  firefox-geckodriver
RUN apt-get remove -y firefox && \
    apt-get update && apt-get install -y software-properties-common && \
    apt-add-repository ppa:mozillateam/ppa && apt update && \
    apt-get install -y firefox-esr

# Install Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Install Helm
RUN apt-get install curl gpg apt-transport-https --yes && \
    curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    apt-get update && \
    apt-get install helm

# VNC password (change as needed)
RUN mkdir -p /root/.vnc && x11vnc -storepasswd 1234 /root/.vnc/passwd

# add postgres db
RUN apt-get update && apt-get install -y postgresql postgresql-contrib vim && \
    sudo -u postgres createuser --superuser root && \
    sudo -u postgres createdb root

RUN mkdir -p /opt/softwareag && chown root:root /opt/softwareag

COPY --from=INSTALL /opt/softwareag/ /opt/softwareag/

# Add custom scripts and supervisor config
COPY ./startup.sh       /
COPY ./supervisord.conf /etc/supervisor/conf.d/
COPY ./xvfb.sh          /usr/local/bin/
RUN chmod +x /usr/local/bin/xvfb.sh


WORKDIR /root
ENV SHELL=/bin/bash
ENV DISPLAY=:1

EXPOSE 6080

ENTRYPOINT ["/startup.sh"]
