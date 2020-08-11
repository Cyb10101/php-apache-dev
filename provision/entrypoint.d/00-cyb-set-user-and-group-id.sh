#!/usr/bin/env sh

updateFiles='0'
if ! getent group ${APPLICATION_GID} >/dev/null 2>&1; then
    groupmod -g ${APPLICATION_GID} application
    updateFiles='1'
fi

if ! getent passwd ${APPLICATION_UID} >/dev/null 2>&1; then
    usermod -u ${APPLICATION_UID} application
    updateFiles='1'
fi

if [ "${updateFiles}" == "1" ]; then
    eval $( fixuid -q )
fi
