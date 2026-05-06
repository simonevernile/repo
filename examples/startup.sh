#!/bin/bash
set -e

USER_NAME='Implementazione'
USER_PASS='TA_POC'

USER_NAME1='weblogic'
GROUP1='oinstall'

# Crea utente se non esiste
id -u ${USER_NAME} &>/dev/null || useradd --create-home --shell /bin/bash ${USER_NAME}

# Imposta password
echo "${USER_NAME}:${USER_PASS}" | chpasswd

# Aggiungi a sudoers
usermod -aG wheel ${USER_NAME}
echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-${USER_NAME}
chmod 0440 /etc/sudoers.d/99-${USER_NAME}

# Crea gruppo se non esiste
getent group "$GROUP1" >/dev/null || sudo groupadd "$GROUP1"

# Crea utente e assegna gruppo primario
if ! id "$USER_NAME1" &>/dev/null; then
  sudo useradd -m -g "$GROUP1" -s /bin/bash "$USER_NAME1"
else
  # Se l'utente già esiste, lo aggiunge al gruppo
  sudo usermod -aG "$GROUP1" "$USER_NAME1"
fi

# Aggiungi a sudoers
usermod -aG wheel ${USER_NAME1}
echo "${USER_NAME1} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-${USER_NAME1}
chmod 0440 /etc/sudoers.d/99-${USER_NAME1}

# Abilita autenticazione con password in SSH
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# Riavvia SSH
systemctl restart sshd

# Installa NFS Utils
dnf install nfs-utils -y

# Installa unzip
dnf install unzip -y

# Monta Share
mount 10.18.182.170:/poc1ashare /mnt
