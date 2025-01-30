#!/usr/bin/env bash
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

echo "Ok attribution PUID et PGID terminé"

# Si aucun argument n'est passé, exécuter une commande par défaut (comme crond)
if [ -z "$1" ]; then
    exec crond -f -l 2
else
    # Exécuter la commande ou le service principal du conteneur
    exec "$@"
fi