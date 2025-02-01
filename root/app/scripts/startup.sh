c#!/usr/bin/env bash
set -e

# Récupérer les valeurs des variables d'environnement PUID et PGID
PUID=${PUID}  # UID par défaut si non défini
PGID=${PGID}  # GID par défaut si non défini
USER="waazaa"

# Vérifier si le groupe avec PGID existe
if ! getent group "$PGID" >/dev/null; then
    echo "The group with GID $PGID didn't exists. 'waazaagroup' created with GID $PGID."
    groupadd -g "$PGID" waazaagroup
fi

# Modifier l'UID et le GID de l'utilisateur waazaa
usermod -u "$PUID" -g "$PGID" "$USER"

# On change le nom
sed -i '/^waazaa:/s/Linux User/Container User/' /etc/passwd

# Mettre à jour les permissions des fichiers appartenant à waazaa
find / -user "$USER" -exec chown "$PUID":"$PGID" {} \;


##############################################################################################################
######  Les scripts locaux dans /app/scripts/ sont lancés un après l'autre par ordre alphanumérique
##############################################################################################################
find /app/scripts/scripts/ -iname "*.sh" | \
while read I; do
    chmod a+x "$I"
    sh "$I"
done

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf