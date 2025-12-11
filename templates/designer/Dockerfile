FROM ubuntu:24.04 AS SERVICE_DESIGNER

RUN mkdir -p /opt/softwareag

COPY wMServiceDesigner.tar.gz /opt/softwareag

RUN set -eux; \
    tar -C /opt/softwareag -xf /opt/softwareag/wMServiceDesigner.tar.gz


FROM ubuntu:24.04

# Build-time args
# CURL_FLAGS: default "-k" (insecure). Override with "" to enforce TLS.
# CUSTOM_CA_CONTENT: optional PEM content for a custom CA (corporate MITM, etc.).
ARG CURL_FLAGS=-k
ARG CUSTOM_CA_CONTENT=""

# built-in packages
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    supervisor sudo net-tools \
    dbus-x11 x11-utils alsa-utils \
    mesa-utils libgl1-mesa-dri \
    xvfb x11vnc \
    lxqt openbox \
    git wget curl python3 python3-pip \
    tini openssl ca-certificates \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Optionally install custom CA certificate (if CUSTOM_CA_CONTENT is provided)
RUN set -eux; \
    if [ -n "$CUSTOM_CA_CONTENT" ]; then \
      echo "Installing custom CA certificate"; \
      echo "$CUSTOM_CA_CONTENT" > /usr/local/share/ca-certificates/custom-ca.crt; \
      update-ca-certificates; \
    else \
      echo "No custom CA content provided, skipping CA install"; \
    fi

# Set up noVNC and websockify
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# Install Firefox ESR by downloading the tarball directly from Mozilla
# Uses $CURL_FLAGS (default "-k") for MITM environments.
ARG FIREFOX_LANG=en-US
ARG FIREFOX_PRODUCT=firefox-esr-latest

RUN set -eux; \
    # Remove distro firefox if present
    apt-get remove -y firefox || true; \
    # Build download URL and fetch archive
    FIREFOX_URL="https://download.mozilla.org/?product=${FIREFOX_PRODUCT}&os=linux64&lang=${FIREFOX_LANG}"; \
    echo "Downloading Firefox from: ${FIREFOX_URL} (curl flags: '$CURL_FLAGS')"; \
    curl $CURL_FLAGS -fL "${FIREFOX_URL}" -o /tmp/firefox-esr.tar.xz; \
    # Extract into /opt/firefox and symlink binary into PATH
    mkdir -p /opt; \
    tar -C /opt -xf /tmp/firefox-esr.tar.xz; \
    ln -sf /opt/firefox/firefox /usr/local/bin/firefox; \
    rm -f /tmp/firefox-esr.tar.xz

# Install kubectl (uses $CURL_FLAGS)
RUN set -eux; \
    KUBECTL_VERSION="$(curl $CURL_FLAGS -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"; \
    echo "Downloading kubectl ${KUBECTL_VERSION} (curl flags: '$CURL_FLAGS')"; \
    curl $CURL_FLAGS -LO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"; \
    chmod +x ./kubectl; \
    mv ./kubectl /usr/local/bin/kubectl

# Install Helm from official binary tarball (no APT repo; uses $CURL_FLAGS)
ARG HELM_VERSION=v3.19.3

RUN set -eux; \
    echo "Downloading Helm ${HELM_VERSION} (curl flags: '$CURL_FLAGS')"; \
    curl $CURL_FLAGS -LO "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz"; \
    tar -xzf "helm-${HELM_VERSION}-linux-amd64.tar.gz"; \
    mv linux-amd64/helm /usr/local/bin/helm; \
    rm -rf "helm-${HELM_VERSION}-linux-amd64.tar.gz" linux-amd64

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
COPY firefox.desktop /usr/share/applications/firefox.desktop

RUN chmod 644 /usr/share/applications/firefox.desktop && \
    chmod +x /usr/local/bin/xvfb.sh /startup.sh && \
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
