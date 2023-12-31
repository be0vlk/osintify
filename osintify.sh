#!/bin/bash

set -e

cd ~
mkdir tools
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y python3 python3-pip bleachbit clamav git recon-ng curl wget default-jre

# Download and install deb packages
declare -a dpkg_links=(
  "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  "https://downloadmirror.hunch.ly/currentversion/hunchly.deb"
  "https://downloads.maltego.com/maltego-v4/linux/Maltego.v4.5.0.deb"
)
declare -a package_names=("google-chrome-stable" "hunchly" "maltego")

for i in "${!dpkg_links[@]}"; do
  if ! dpkg -l | grep -q "${package_names[$i]}"; then
    deb_file="${dpkg_links[$i]##*/}"
    wget "${dpkg_links[$i]}"
    sudo dpkg -i "$deb_file"
    rm "$deb_file"
  else
    echo "Package ${package_names[$i]} is already installed, skipping download."
  fi
done

# Clone GitHub repos
if [ ! -d "~/tools/Fast-Google-Dorks-Scan" ]; then
  git clone https://github.com/IvanGlinkin/Fast-Google-Dorks-Scan.git ~/tools/Fast-Google-Dorks-Scan
fi
if [ ! -d "~/tools/owlculus" ]; then
  git clone https://github.com/be0vlk/owlculus.git ~/tools/owlculus
fi
sudo chmod +x ~/tools/Fast-Google-Dorks-Scan/FGDS.sh
echo "alias fgds='~/tools/Fast-Google-Dorks-Scan/FGDS.sh'" >> ~/.bash_aliases
echo "alias owlculus='python3 ~/tools/owlculus/owlculus'" >> ~/.bash_aliases
echo "alias update=\"{ echo '[*] Getting apt updates'; sudo apt update; sudo apt upgrade -qq -y; } && for repo in ~/tools/*; do [ -d \\\"$repo/.git\\\" ] && { repo_name=\\\$(basename \\\"$repo\\\"); printf '\\n[*] Updating %s \\n' \\$repo_name; (cd \\\"$repo\\\" && git pull); }; done\"" >> ~/.bash_aliases

# Install Python packages
pip3 install maigret shodan
pip3 install -r ~/tools/owlculus/requirements.txt

# Install Chrome extensions
declare -A EXTlist=(
    ["bitwarden"]="nngceckbapebfimnlniiiahkandclblb"
    ["facecheck"]="ciocmmdeghlmioiedoggnlefllfpfmdj"
    ["single-file"]="mpiodijhokgodhhofbcjdecpffjipkle"
    ["fireshot"]="mcbpblocgmgfnpjjppndjkmgjaogfceg"
    ["trufflehog"]="bafhdnhjnlcdbjcdcnafhdcphhnfnhjc"
    ["ublock-origin"]="cjpalhdlnbpafiamejdnhcphjbkeiagm"
    ["onetab"]="chphlpgkkbolifaimnlloiipkdnihall"
    ["down-them-all"]="nljkibfhlpcnanjgbnlnbjecgicbjkge"
)

(
for i in "${!EXTlist[@]}"; do
   echo "echo '{\"external_update_url\": \"https://clients2.google.com/service/update2/crx\"}' > /opt/google/chrome/extensions/${EXTlist[$i]}.json"
done
) | sudo sh

# Install ModernCSV
sudo wget "https://www.moderncsv.com/release/ModernCSV-Linux-v2.0.2.tar.gz" -P /opt
sudo tar -xzf /opt/ModernCSV-Linux-v2.0.2.tar.gz -C /opt
sudo rm /opt/ModernCSV-Linux-v2.0.2.tar.gz
sudo  bash /opt/moderncsv2.0.2/install.sh

# Fix any broken installations
sudo apt --fix-broken install

# Prompt user to press enter to reboot
echo "[*] Press enter to reboot"
read
sudo reboot
