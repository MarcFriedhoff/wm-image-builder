#!/bin/bash
set -e

# Use writable temp directory for password files and configs
TEMP_DIR="${HOME}/.vnc"
CONFIG_DIR="${HOME}/.config/supervisor"
mkdir -p "${TEMP_DIR}" "${CONFIG_DIR}"


# Copy supervisord config to writable location
cp /etc/supervisor/conf.d/supervisord.conf "${CONFIG_DIR}/supervisord.conf"
SUPERVISOR_CONF="${CONFIG_DIR}/supervisord.conf"

# Set VNC password (use environment variable or default)
VNC_PASSWORD=${VNC_PASSWORD:-1234}
echo -n "$VNC_PASSWORD" > "${TEMP_DIR}/.password1"
x11vnc -storepasswd $(cat "${TEMP_DIR}/.password1") "${TEMP_DIR}/.password2"
chmod 400 "${TEMP_DIR}"/.password*
sed -i "s|^command=x11vnc.*|& -rfbauth ${TEMP_DIR}/.password2|" "${SUPERVISOR_CONF}"

# Print the noVNC access URL
echo "=========================================="
echo "noVNC Access:"
echo "http://localhost:6080/"
echo ""
echo "When you click 'Connect', noVNC will prompt for:"
echo "Password: ${VNC_PASSWORD}"
echo ""
echo "To change password, set VNC_PASSWORD environment variable"
echo "=========================================="

if [ -n "$X11VNC_ARGS" ]; then
    sed -i "s/^command=x11vnc.*/& ${X11VNC_ARGS}/" "${SUPERVISOR_CONF}"
fi

if [ -n "$OPENBOX_ARGS" ]; then
    sed -i "s#^command=/usr/bin/openbox\$#& ${OPENBOX_ARGS}#" "${SUPERVISOR_CONF}"
fi

if [ -n "$RESOLUTION" ]; then
    # Copy xvfb.sh to writable location if we need to modify it
    if [ ! -w /usr/local/bin/xvfb.sh ]; then
        cp /usr/local/bin/xvfb.sh "${HOME}/.local/bin/xvfb.sh"
        chmod +x "${HOME}/.local/bin/xvfb.sh"
        sed -i "s/1024x768/$RESOLUTION/" "${HOME}/.local/bin/xvfb.sh"
        # Update supervisor config to use the copied script
        sed -i "s|/usr/local/bin/xvfb.sh|${HOME}/.local/bin/xvfb.sh|" "${SUPERVISOR_CONF}"
    else
        sed -i "s/1024x768/$RESOLUTION/" /usr/local/bin/xvfb.sh
    fi
fi

USER=${USER:-sagadmin}
HOME=${HOME:-/home/$USER}

# Only attempt user creation if running as root (not in OpenShift)
if [ "$(id -u)" = "0" ] && [ "$USER" != "root" ]; then
    echo "* Running as root, checking user: $USER"
    if ! id "$USER" &>/dev/null; then
        echo "* Creating user: $USER"
        useradd --create-home --shell /bin/bash --user-group --groups adm,sudo $USER
        if [ -z "$PASSWORD" ]; then
            echo "  set default password to \"ubuntu\""
            PASSWORD=ubuntu
        fi
        echo "$USER:$PASSWORD" | chpasswd
    fi
    chown -R $USER:$USER ${HOME}
    [ -d "/dev/snd" ] && chgrp -R adm /dev/snd
else
    echo "* Running as non-root user (UID: $(id -u)), using existing user: $USER"
fi

# Replace placeholders in supervisord config
sed -i -e "s|%USER%|$USER|g" -e "s|%HOME%|$HOME|g" "${SUPERVISOR_CONF}"

# Create a temporary supervisord main config that includes our modified conf
cat > "${HOME}/.config/supervisor/supervisord-main.conf" << EOF
[supervisord]
nodaemon=true
logfile=/tmp/supervisord.log
pidfile=/tmp/supervisord.pid

[include]
files = ${SUPERVISOR_CONF}
EOF

exec /usr/bin/tini -- supervisord -n -c "${HOME}/.config/supervisor/supervisord-main.conf"