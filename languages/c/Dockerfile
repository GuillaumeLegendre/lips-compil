FROM ubuntu
RUN apt-get update
RUN apt-get install -y gcc coreutils
ADD script.sh /root/script.sh
ADD timeout.sh /root/timeout.sh
RUN chmod +x /root/script.sh
RUN chmod +x /root/timeout.sh
