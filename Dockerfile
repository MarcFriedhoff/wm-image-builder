# Use base image ...
ARG BASE_IMAGE
ARG INSTALL_BASE_IMAGE

FROM ${INSTALL_BASE_IMAGE:-${BASE_IMAGE}} as INSTALL
ARG ENTITLEMENT_USER
ARG ENTITLEMENT_KEY
ARG INSTALLER=installer.bin
ARG INSTALLER_VERSION
ARG RELEASE
ARG ADMIN_PASSWORD
ARG PRODUCTS
ARG DEBUG=false

# Following parameters are needed ...
#   Empower credentials ...

ENV DEBUG=${DEBUG}

# Install basis software ...
#   if you use ubuntu:latest, enable ...
# RUN \
#   apt-get update                                && \
#   apt-get upgrade                            -y && \
#   apt-get install curl                       -y

COPY ${INSTALLER} /installer.bin

COPY installer.script.tmp /installer.script.tmp

# Create user ...
RUN useradd -ms /bin/bash sagadmin

# Create installation directory ...
RUN mkdir -p  /opt/softwareag/
RUN mkdir -p /installer/templates/
RUN chown sagadmin /opt/softwareag
RUN chmod +x /installer.bin

# set user home directory
ENV SAG_HOME=/opt/softwareag

# Install tools depending on the base image
RUN . /etc/os-release; \
    echo "Base: $ID $VERSION_ID"; \
    if echo "$ID $ID_LIKE" | grep -qi 'rhel\|ubi\|centos\|fedora'; then \
        case "$VERSION_ID" in \
          8*) dnf install -y shadow-utils procps-ng tar ;; \
          9*) if command -v microdnf >/dev/null 2>&1; then \
                  microdnf install -y shadow-utils coreutils-single procps tar gzip; \
               else \
                  dnf install -y shadow-utils procps-ng tar; \
               fi ;; \
          *) echo "Unsupported RHEL/UBI version: $VERSION_ID" >&2; exit 1 ;; \
        esac; \
        (dnf clean all || microdnf clean all || true); \
        rm -rf /var/cache/*; \
    elif echo "$ID $ID_LIKE" | grep -qi 'debian\|ubuntu'; then \
        apt-get update && apt-get install -y procps tar && \
        rm -rf /var/lib/apt/lists/*; \
    elif [ "$ID" = "alpine" ]; then \
        apk add --no-cache procps tar; \
    else \
        echo "Unknown base image: $ID (like: $ID_LIKE) $VERSION_ID" >&2; exit 1; \
    fi

# install process tools on redhat/ubi9-minimal
#RUN microdnf install -y shadow-utils coreutils-single procps tar gzip \
# && microdnf clean all \
# && rm -rf /var/cache/*

ENV PRODUCTS=${PRODUCTS}

RUN echo "PRODUCTS: ${PRODUCTS}"

FROM INSTALL as INSTALLER

ARG ENTITLEMENT_USER
ARG ENTITLEMENT_KEY
ARG INSTALLER_VERSION
ARG RELEASE
ARG ADMIN_PASSWORD
ARG PRODUCTS
ARG DEBUG=false

# Create script for Software AG Installer ...
RUN \
    echo "ServerURL=https\://sdc.webmethods.io/cgi-bin/dataservewebM`echo ${RELEASE} | sed "s/\.//g"`.cgi"            > installer.script && \
    echo "selectedFixes=spro\:all"                                                                                       >> installer.script && \
    echo "InstallProducts=`for item in $(echo ${PRODUCTS} | sed "s/,/ /g");  do printf e2ei/11/.LATEST/*/$item, ; done`" >> installer.script && \ 
    echo "InstallDir=/opt/softwareag"                                                                                    >> installer.script && \
    echo "adminPassword=${ADMIN_PASSWORD}"                                                                               >> installer.script && \
    echo "Username=${ENTITLEMENT_USER}"                                                                                  >> installer.script && \
    echo "Password=${ENTITLEMENT_KEY}"                                                                                   >> installer.script && \
    cat /installer.script.tmp                                                                                                  >> installer.script

RUN echo 'Debug Installer script: ' && echo && cat installer.script

# Install software ...
#   and Change user context to ...
USER root

WORKDIR /opt/softwareag

# run only if debug mode is not enabled
RUN if [ "$DEBUG" = "false" ]; then \
      echo "Running installer with DEBUG=$DEBUG" && \
      sh /installer.bin -readScript /installer.script -console; \
    else \
      echo "Skipping installer because DEBUG=$DEBUG"; \
    fi


RUN echo 'Debug installation log ...' && echo && true || cat /opt/softwareag/install/installLog.txt

