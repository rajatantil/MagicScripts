#!/bin/bash

result=$(grep -i "Amazon Linux" /etc/os-release | head -1)
rhel_ver=$(awk -F'=' '/VERSION_ID/{ gsub(/"/,""); print $2}' /etc/os-release)

configure_atop() {
    sed -i 's/^LOGINTERVAL=600.*/LOGINTERVAL=300/' /etc/default/atop
    sed -i 's/^LOGGENERATIONS=28.*/LOGGENERATIONS=14/' /etc/default/atop
	systemctl enable atop
	systemctl restart atop
}

if [ -n "$result" ]; then
	yum install https://www.atoptool.nl/download/atop-2.7.1-1.el7.x86_64.rpm -y
    configure_atop
elif [ `echo $rhel_ver | awk -F'.' '{print $1}'` -eq 7 ]; then
	echo "RHEL 7"
	yum install https://www.atoptool.nl/download/atop-2.7.1-1.el7.x86_64.rpm -y
    configure_atop
elif [ `echo $rhel_ver | awk -F'.' '{print $1}'` -eq 8 ]; then
    echo "RHEL 8"
	yum install https://www.atoptool.nl/download/atop-2.10.0-1.el8.x86_64.rpm -y
    configure_atop
elif [ `echo $rhel_ver | awk -F'.' '{print $1}'` -eq 9 ]; then
    echo "RHEL 9"
	yum install https://www.atoptool.nl/download/atop-2.11.0-1.el9.x86_64.rpm -y
    configure_atop
else
    echo "We cannot detect your OS"
    exit 2
fi
