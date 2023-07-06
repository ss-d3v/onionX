#!/bin/bash

set -euo pipefail

nc="\033[00m"
red="\033[01;31m"
green="\033[01;32m"
yellow="\033[01;33m"
blue="[debug]\033[01;34m"
purple="\033[01;35m"
cyan="\033[01;36m"

# default constant values
port="1337"
tordir=$PWD/hidden_service

logo="${yellow}__              ____  __ ${red}
${yellow}  ____   ____ |__| ____   ____ ${red}\   \/ /
${yellow} / __ \ /    \|  |/ __ \ /    \ ${red}\    / 
${yellow}(  \_\ )   |  \  |  \_\ )   |  ${red}\/    \ 
${yellow} \____/|___|  /__|\____/|___|  ${red}/___/\ \
${yellow}            \/               \/${red}      \/
${cyan} A dark web website for everyone 
${nc}"

contact="${yellow}YouTube -      ${purple}https://youtube.com/c/pwnos
${yellow}LinkedIn -     ${purple}https://linkedin.com/in/sam-sepi0l/
${yellow}Twitter -      ${purple}https://twitter.com/sam5epi0l
${yellow}Buymeacoffee - ${purple}https://www.buymeacoffee.com/sam5epi0l

${nc}"

printf "%s %s\n" "$logo" "$contact"
sleep 1
# checking for system root access
if command -v sudo >/dev/null; then
  sudo="sudo"
  printf "${blue} Script will require sudo/root privileges${nc}\n"
else
  sudo=""
  printf "${blue}You're powerful enough to install packages${nc}\n"
fi
sleep 1

# checking for system home dir
if (( "${#HOME}" == 0 )); then
  HOME="$(getent passwd "$(id -u)" | awk -F ':' '{print $6}')"
  if (( "${#HOME}" == 0 )) || [[ ! -d "${HOME}" ]]; then
    printf "${blue}%s${nc}\n" "Could not identify HOME variable" >&2
    exit 1
  fi
  if [[ ! -w "${HOME}" ]]; then
    printf "${blue}%s${nc}\n" "Permissions error: cannot write to $HOME" >&2
    exit 1
  fi
  export HOME
fi

printf "${blue} You live at ${green} %s ${nc}\n" "$HOME"
sleep 1
# checking for configuration dir
if [[ -d /data/data/com.termux/files/usr/etc ]]; then
  tor_conf_dir="/data/data/com.termux/files/usr/etc/tor"
elif [[ -d /etc ]]; then
  tor_conf_dir="/etc/tor"
fi

printf "${blue} TOR default configurations are here ${green} %s ${nc}\n" "$tor_conf_dir"
sleep 1
# checking for system bin dir
if [[ -d /data/data/com.termux/files/usr/bin ]]; then
  bin="/data/data/com.termux/files/usr/bin"
elif [[ -d /sbin ]]; then
  bin="/sbin"
elif [[ -d /bin ]]; then
  bin="/bin"
elif [[ -d /usr/local/bin ]]; then
  bin="/usr/local/bin"
fi

printf "${blue} Your bin directory is here %s ${nc}\n" "$bin"
sleep 1
# checking for system package manager
if [[ -e /data/data/com.termux/files/usr/bin/pkg ]]; then
  pac="pkg"
  system="termux"
elif command -v apt >/dev/null; then
  pac="apt"
  system="linux"
elif command -v apt-get >/dev/null; then
  pac="apt-get"
  system="linux"
elif command -v apk >/dev/null; then
  pac="apk"
  system="linux"
elif command -v yum >/dev/null; then
  pac="yum"
  system="fedora"
elif command -v brew >/dev/null; then
  pac="brew"
  system="mac"
  sudo=""
fi

printf "${blue} Your system is %s and %s is the package manager ${nc}\n" "$system" "$pac"
sleep 1
printf "${blue} You are currently installing in %s directory ${nc}\n" "$PWD"
sleep 1
# setup process

printf "[-]${green} Installing .... ${nc}\n"
sleep 1
printf "[-]${yellow} Running setup .... ${nc}\n"
sleep 1

# installing dependency

# $sudo $pac update -y

#for each_pac in "tor"; do
if ! command -v tor >/dev/null; then
  if [[ "$sudo" ]]; then
    printf "${blue} Installing tor with sudo${nc}\n"
    $sudo $pac install tor -y
  else
    printf "${blue} Installing tor without sudo ${nc}\n"
    $pac install tor -y
  fi
fi
#done
sleep 1

# setup tor hidden service [error]

printf "[-] ${yellow} starting tor hidden service on port %s ${red} change it if port is unavailable ${nc}\n" "$port"
sleep 1
printf "[-]${green} tor hidden service dir is here ${cyan} %s ${nc}\n" "$tordir"
sleep 1
printf "${blue} configuring torrc file\n"


cp "$tor_conf_dir/torrc" .
echo "HiddenServiceDir $PWD/hidden_service/" >> torrc
echo "HiddenServicePort 80 127.0.0.1:$port" >> torrc

# Start tor service
printf "[-] ${yellow} Starting tor hidden service ${nc}\n"
sleep 1
tor -f torrc --quiet &
printf "[-] ${red} tor started ${nc}\n"
sleep 1

# check onionX is installed or not
if [[ -e "$bin/tor" ]]; then
  echo "pass"
  if [[ -d "$tordir" ]]; then
    printf "%s\n" "$logo"
    printf "[i]${purple} onionX ${green}installed successfully !!${nc}\n"
    sleep 1
    printf "[i]${green} Start your apache/nginx server on port %s ${nc}\n" "$port"
    sleep 1
    printf "[i]${yellow} Check out your Website here - %s ${nc}\n" "$(cat hidden_service/hostname)"
    sleep 1
    printf "[i]${purple} got errors, contact me here %s ${nc}\n" "$contact"
  else
    printf "%s\n" "$logo"
    sleep 1
    printf "[i] ${red}Sorry ${cyan}: onionx ${red}is not installed !!${nc}\n"
    sleep 1
    printf "[i] ${green}Please try again or contact me here %s ${nc}\n" "$contact"
  fi
fi
