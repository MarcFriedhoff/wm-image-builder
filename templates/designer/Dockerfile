FROM ubuntu:24.04 AS SERVICE_DESIGNER

RUN mkdir -p /opt/softwareag

COPY wMServiceDesigner.tar.gz /opt/softwareag

RUN set -eux; \
    tar -C /opt/softwareag -xf /opt/softwareag/wMServiceDesigner.tar.gz


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
    tini openssl \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set up noVNC and websockify
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# Install Firefox Browser (ESR) without apt-add-repository
# Uses Mozilla's official APT repository (no Launchpad/IPv6 issues)
RUN set -eux; \
    apt-get remove -y firefox || true; \
    apt-get update; \
    install -d -m 0755 /etc/apt/keyrings; \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- \
      | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null; \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
      > /etc/apt/sources.list.d/mozilla.list; \
    printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' \
      > /etc/apt/preferences.d/mozilla; \
    apt-get update; \
    apt-get install -y firefox-esr; \
    rm -rf /var/lib/apt/lists/*

# Install Kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

# Install Helm
RUN apt-get update && apt-get install -y curl gpg apt-transport-https && \
    curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey \
      | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" \
      > /etc/apt/sources.list.d/helm-stable-debian.list && \
    apt-get update && \
    apt-get install -y helm && \
    rm -rf /var/lib/apt/lists/*
RUN dpkg -l | grep screensaver | awk '{ print $2 }' | xargs dpkg --remove

# Create non-root user
RUN useradd --uid 1724 --create-home --shell /bin/bash --user-group --groups adm,sudo sagadmin && \
    echo "sagadmin:sagadmin" | chpasswd

# VNC password (change as needed)
RUN mkdir -p /home/sagadmin/.vnc && \
    x11vnc -storepasswd 1234 /home/sagadmin/.vnc/passwd && \
    chown -R sagadmin:0 /home/sagadmin/.vnc && \
    chmod -R g=u /home/sagadmin/.vnc

RUN mkdir -p /opt/softwareag && \
    chown sagadmin:0 /opt/softwareag && \
    chmod g=u /opt/softwareag

COPY --from=SERVICE_DESIGNER --chown=sagadmin:0 /opt/softwareag/wMServiceDesigner/ /opt/softwareag/wMServiceDesigner

# Add custom scripts and supervisor config
COPY ./startup.sh       /
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./xvfb.sh          /usr/local/bin/
COPY ./custom-novnc.css /opt/novnc/app/styles/custom.css
COPY ./webmethods-vnc.html /opt/novnc/vnc.html
COPY designer.desktop  /home/sagadmin/Desktop/designer.desktop

RUN chmod +x /usr/local/bin/xvfb.sh /startup.sh && \
    chmod 644 /etc/supervisor/conf.d/supervisord.conf && \
    chmod 644 /opt/novnc/app/styles/custom.css && \
    chmod 644 /opt/novnc/vnc.html && \
    mkdir -p /home/sagadmin/.config/supervisor /home/sagadmin/.local/bin && \
    chown -R sagadmin:0 /home/sagadmin && \
    chmod -R g=u /home/sagadmin

WORKDIR /home/sagadmin
ENV SHELL=/bin/bash
ENV DISPLAY=:1
ENV USER=sagadmin
ENV HOME=/home/sagadmin

EXPOSE 6080

USER sagadmin

ENTRYPOINT ["/startup.sh"]
