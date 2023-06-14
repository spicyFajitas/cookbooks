#!/bin/bash
# first time setup script for new debian-based installations


echo -e "

  # #     # #         #                                          # #     # #
  # #     # #        # #   ###### ##### ###### #####             # #     # #
####### #######     #   #  #        #   #      #    #          ####### #######
  # #     # #      #     # #####    #   #####  #    #            # #     # #
####### #######    ####### #        #   #      #####           ####### #######
  # #     # #      #     # #        #   #      #   #             # #     # #
  # #     # #      #     # #        #   ###### #    #            # #     # #

  # #     # #      ###                                               # #     # #
  # #     # #       #  #    #  ####  #####   ##   #      #           # #     # #
####### #######     #  ##   # #        #    #  #  #      #         ####### #######
  # #     # #       #  # #  #  ####    #   #    # #      #           # #     # #
####### #######     #  #  # #      #   #   ###### #      #         ####### #######
  # #     # #       #  #   ## #    #   #   #    # #      #           # #     # #
  # #     # #      ### #    #  ####    #   #    # ###### ######      # #     # #

  # #     # #       #####                                       # #     # #
  # #     # #      #     #  ####  #####  # #####  #####         # #     # #
####### #######    #       #    # #    # # #    #   #         ####### #######
  # #     # #       #####  #      #    # # #    #   #           # #     # #
####### #######          # #      #####  # #####    #         ####### #######
  # #     # #      #     # #    # #   #  # #        #           # #     # #
  # #     # #       #####   ####  #    # # #        #           # #     # #

"
####################

echo -e "\n\n"


mkdir -p ~/.ssh

# echo "################################################################################"
# echo -e "adding Adam's macbook SSH key to this machine"
# echo "################################################################################"
# echo -e "\n\n"
# echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKlWUHi61l2BmJKJTSU/uC+fa2H1a73VdmDxmcwCZRo adam@Fajita-MacBook.lan" >> ~/.ssh/authorized_keys


# echo "################################################################################"
# echo -e "adding ansible-server's SSH key to this machine"
# echo "################################################################################"
# echo -e "\n\n"
# echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAqz7vI3Iur9UmtKiXpH6zNkieG65xjETZuwdUHDTArw root@ansible-server" >> ~/.ssh/authorized_keys

sleep 5
echo "################################################################################"
echo -e "running apt update -y"
echo "################################################################################"
echo -e "\n\n"
sleep 2
sudo apt update

echo -e "\n\n"
echo "################################################################################"
echo -e "installing git, neofetch, net-tools, and vim"
echo "################################################################################"
echo -e "\n\n"
sleep 5
sudo apt --assume-yes install vim git net-tools neofetch

echo -e "\n\n"
echo "################################################################################"
echo -e "installing docker"
echo "################################################################################"
echo -e "\n\n"
sleep 5
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
sudo apt-get install ca-certificates curl gnupg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


echo -e "\n\n"
echo "################################################################################"
echo -e "enabling SSH"
echo "################################################################################"
echo -e "\n\n"

systemctl enable ssh && systemctl start ssh

echo -e "\n\n"
echo "################################################################################"
echo -e "running apt upgrade -y"
echo "################################################################################"
echo -e "\n\n"
sudo apt upgrade -y


echo -e "\n\n"
echo "################################################################################"
echo -e "running apt autoremove"
echo "################################################################################"
echo -e "\n\n"
sudo apt autoremove -y
