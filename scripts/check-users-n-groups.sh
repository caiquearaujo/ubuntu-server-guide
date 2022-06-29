#!/bin/bash
# Obtem o nome do grupo a ser perquisado
getent group | cut -d":" -f1 | while IFS=: read -r groupname; do
    # Obtem o ID do groupo
    gid=$(cat /etc/group | grep ^"$groupname": | cut -d":" -f3)
    # Confere todos os usuários que utilizam o grupo
    used="false"
    for name in $(getent passwd | cut -d":" -f1);
    do
        is_member=$(id -G "$name" | grep "$gid")
        if [ ! -z "$is_member" ]
        then
            used="true"
        fi
    done

    if [ "$used" = "false" ] ; then
        echo "O grupo $groupname não é utilizado..."
    fi
done