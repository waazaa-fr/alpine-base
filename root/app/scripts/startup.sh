#!/usr/bin/env bash
set -e

##############################################################################################################
######  Les scripts locaux dans /app/scripts/ sont lancés un après l'autre par ordre alphanumérique
##############################################################################################################
find /app/scripts/scripts/ -iname "*.sh" | \
while read I; do
    chmod a+x "$I"
    sh "$I"
done

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf