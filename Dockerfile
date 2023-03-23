FROM ubuntu
RUN apt update

WORKDIR /app
COPY requirements.txt requirements.txt
RUN apt install python3-pip -y
RUN pip3 install -r requirements.txt

## Create a Non-Root User
RUN apt-get update && apt-get -y install sudo && apt-get install wget -y && apt-get install curl -y
RUN useradd -m developer && echo "developer:developer" | chpasswd && adduser developer sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

## Switch to Non-Root User
USER developer
WORKDIR /home/developer/

## Install Node
RUN sudo curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
RUN sudo bash nodesource_setup.sh
RUN sudo apt install nodejs -y

## Install Git
RUN sudo apt install git -y
ARG gitusername
ARG gitemail
ENV gitun=$gitusername
ENV gitemail=$gitemail
RUN git config --global user.name "$gitun"
RUN git config --global user.email "$gitemail"

## Install Python3
RUN sudo apt-get install python3 python3-dev -y

## Install Java 17
RUN sudo wget https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_linux-x64_bin.tar.gz
RUN sudo tar xvf openjdk-17_linux-x64_bin.tar.gz
RUN sudo mv jdk-17 /opt/
RUN echo 'JAVA_HOME=/opt/jdk-17' >> ~/.bashrc
RUN echo 'PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
RUN . ~/.bashrc

## Installing PHP
RUN DEBIAN_FRONTEND=noninteractive TZ="America/New York" sudo -E apt-get -y install tzdata
RUN sudo apt install -y software-properties-common
RUN sudo add-apt-repository ppa:ondrej/php
RUN sudo apt update
RUN sudo apt install php8.0 -y

## Installing Composer
RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
RUN sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

## Install Nano + VIM for editing
RUN sudo apt-get install nano vim -y


COPY . .
CMD ["python3","-m","flask","run","--host=0.0.0.0"]