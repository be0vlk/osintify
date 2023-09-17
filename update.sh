#! /bin/bash

echo "[*] Getting apt updates"
sudo apt update
sudo apt upgrade -qq -y

for repo in ~/tools/*; do
    if [ -d "$repo/.git" ]; then
        repo_name=$(basename "$repo")
        printf "\n[*] Updating %s \n" "$repo_name"
        (cd "$repo" && git pull)
    fi
done
