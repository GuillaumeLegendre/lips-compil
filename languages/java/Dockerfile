FROM ubuntu

RUN sudo apt-get update
RUN sudo apt-get install -y coreutils
# openjdk-7-jdk

ADD script.sh /root/script.sh
ADD timeout.sh /root/timeout.sh
RUN chmod +x /root/script.sh
RUN chmod +x /root/timeout.sh
