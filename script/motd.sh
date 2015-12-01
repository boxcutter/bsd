#!/bin/sh -u

echo "==> Recording box generation date";
date > /etc/vagrant_box_build_date

echo "==> Customizing message of the day";
MOTD_FILE=/etc/motd
BANNER_WIDTH=64
PLATFORM_OS=$(uname -s);
PLATFORM_RELEASE=$(uname -r);
PLATFORM_ARCH=$(uname -m);
PLATFORM_MSG=$(printf '%s' "$PLATFORM_OS $PLATFORM_RELEASE $PLATFORM_ARCH")
BUILT_MSG=$(printf 'built %s' $(date +%Y-%m-%d))
printf '%0.64s' "-------------------------------------------------------------------------------------------------------------------------" > ${MOTD_FILE}
printf '\n' >> ${MOTD_FILE}
printf '%2s%-30s%30s\n' " " "${PLATFORM_MSG}" "${BUILT_MSG}" >> ${MOTD_FILE}
printf '%0.64s' "-------------------------------------------------------------------------------------------------------------------------" >> ${MOTD_FILE}
printf '\n' >> ${MOTD_FILE}
