sudo apt install -y snapd
sudo snap install core
sudo snap install lxd
sudo usermod -aG lxd "$USER"
newgrp lxd
