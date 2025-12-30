#!/bin/bash
echo "Downloading and preparing Remnawave installer..."
wget -O install_temp.sh https://raw.githubusercontent.com/xGuliyev/Remnawave-AutoSetup/main/install_remnawave.sh
sed -i 's/\r$//' install_temp.sh
mv install_temp.sh install_remnawave.sh
chmod +x install_remnawave.sh
./install_remnawave.sh
