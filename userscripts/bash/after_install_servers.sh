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

echo "################################################################################"
echo -e "adding Adam's macbook SSH key to this machine"
echo "################################################################################"
echo -e "\n\n"
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICKlWUHi61l2BmJKJTSU/uC+fa2H1a73VdmDxmcwCZRo adam@Fajita-MacBook.lan" >> ~/.ssh/authorized_keys


echo "################################################################################"
echo -e "adding ansible-server's SSH key to this machine"
echo "################################################################################"
echo -e "\n\n"
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAqz7vI3Iur9UmtKiXpH6zNkieG65xjETZuwdUHDTArw root@ansible-server" >> ~/.ssh/authorized_keys

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
echo -e "enabling SSH"
echo "################################################################################"
echo -e "\n\n"

systemctl enable ssh && systemctl start ssh

echo -e "\n\n"
echo "################################################################################"
echo -e "cloning Cookbooks repo and Docker Testing repo"
echo "################################################################################"
echo -e "\n\n"
git clone https://github.com/spicyFajitas/cookbooks.git
git clone https://github.com/spicyFajitas/KinD-testing.git

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