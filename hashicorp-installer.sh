#!/usr/bin/env bash
set -e
shopt -s nocasematch

echo "detecting os"
if [ -f /etc/lsb-release ]; then
    SYSTEM=$(. /etc/lsb-release && echo $DISTRIB_ID)
    echo "detected $SYSTEM"
    elif [ -f /etc/os-release ]; then
    SYSTEM=$(awk -F= '/^ID=/{print $2}' /etc/os-release | tr -d \")
    echo "detected $SYSTEM"
else
    echo "Unsupported Linux distribution"
    exit 1
fi


if [[ $SYSTEM =~ ^(ubuntu|debian)$ ]]; then
    if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
        echo "updating apt and installing gpg package \n"
        apt update && apt install -y gpg
        echo "get gpg key of hashicorp repo \n"
        wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "check key fingerprint \n"
        gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint
        echo "adding repo file" \n
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
        echo "updating apt db"
        apt update
    fi
    products=($(grep ^Package: /var/lib/apt/lists/apt.releases.hashicorp.com*Packages | awk '{print $2}' | sort -u))
    
    
    elif [[ $SYSTEM =~ ^(rhel|centos|fedora|amazonlinux)$ ]]; then
    if [ ! -f /etc/yum.repos.d/hashicorp.repo ]; then
        echo "installing gpg"
        yum update && yum install -y gnupg wget
        echo "checking for gpg fingerprint"
        # rpm -qa gpg-pubkey* --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n' | grep hashicorp
        echo "adding hashicorp repo"
        if [[ $SYSTEM == "rhel" || $SYSTEM == "centos" ]]; then
            SYSTEM_URL="RHEL"
            elif [[ $SYSTEM == "fedora" ]]; then
            SYSTEM_URL="fedora"
            elif [[ $SYSTEM == "amazonlinux" ]]; then
            SYSTEM_URL="AmazonLinux"
        fi
        wget -O- https://rpm.releases.hashicorp.com/$SYSTEM_URL/hashicorp.repo | tee /etc/yum.repos.d/hashicorp.repo
        
        yum update
    fi
    products=($(yum repository-packages hashicorp list | grep hashicorp | awk '{print $1}' | sed 's/\..*//' | sort -u))
else
    echo "Unsupported system: $SYSTEM"
    exit 1
fi


echo "available hashicorp product are: "
for i in "${!products[@]}"; do
    printf "%s. %s\n" "$((i+1))" "${products[$i]}"
done


# Ask user for product(s) to install
read -p "Enter product number(s) to install (comma separated for multiple): " product_input

# Install selected product(s)
IFS=',' read -ra product_nums <<< "$product_input"
for product_num in "${product_nums[@]}"; do
    index=$((product_num-1))
    if [[ "$index" -ge "0" && "$index" -lt "${#products[@]}" ]]; then
        product="${products[$index]}"
        echo "Installing $product"
        if [[ $SYSTEM == "ubuntu" ]]; then
            apt install "$product" -y
            echo "Installed $product"
        elif [[ $SYSTEM =~ ^(rhel|centos|fedora|amazonlinux)$ ]]; then
            yum install "$product" -y
            echo "Installed $product"
        fi
    else
        if [[ ! " ${products[@]} " =~ " ${product} " ]]; then
            echo "Invalid product name: $product_nums"
        fi
    fi

done

