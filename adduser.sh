#!/bin/bash

adduser()
{
echo -n "Enter user name "
read username
export username
echo -n "Enter user password "
read password
export password


for i in $(cat host.txt)
do

user=root
echo $i

ssh -A  $user@$i password=$password username=$username 'bash -s' <<'ENDSSH'

if [ $(id -u) -eq 0 ]; then

        egrep "^$username" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                printf "=========================\n"
                echo "$username is already exists!"
                exit 1
        else
                pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
                useradd -m -p $pass -s /bin/bash $username
                sed -i "/AllowUsers/ s/$/ $username/" /etc/ssh/sshd_config
                /etc/init.d/sshd reload
                [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
        fi
else
        echo "Only root can add a user to the system"
        exit 2
fi
ENDSSH

done
}

delete()
{
echo -n "Enter user name "
read username
export username

for i in $(cat host.txt)
do

user=root
echo $i

ssh -A  $user@$i username=$username 'bash -s' <<'ENDSSH'

echo "deleting user from server"
        if [ $(id -u) -eq 0 ]; then
        egrep "^$username" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                printf "=========================\n"
                echo "deleting user"
                userdel $username
                 exit 1
        else
                echo "User is alredy deleted"
        fi
else
        echo "Only root can delete a user to the system"
        exit 2
fi

ENDSSH

done
}

ssh_denied()
{
echo -n "Enter user name "
read username
export username

for i in $(cat host.txt)
do

user=root
echo $i

ssh -A  $user@$i username=$username 'bash -s' <<'ENDSSH'

echo "removing ssh access from server"
                echo "deleting entry from sshd_config file"
                sed -i "s/$username//g" /etc/ssh/sshd_config
                /etc/init.d/sshd reload

ENDSSH

done
}

echo "1. Add new user"
echo "2. Delete access"
echo "3. Removing ssh access"
echo "4. Quit"


read -p "Enter your choice [ 1 - 4 ] " choice
case $choice in

        1)
                echo "Adding User"
                adduser

                ;;
        2)
                echo "Deletting User Account "
                delete
                ;;
        3)      echo "Removing SSH access"
                ssh_denied
                ;;
        4)
                exit
                ;;

                *)
                echo "Error: Invalid option..."
                read -p "Press [Enter] key to continue..." readEnterKey
               ;;

esac

