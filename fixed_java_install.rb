#!/usr/bin/env ruby

system("docker run -privileged ubuntu:java apt-get install -y openjdk-7-jdk")

res = `docker ps -l`
res = res.split("ubuntu:java")[0]
res = res.split("NAMES\n")[1].strip

system("docker commit #{res} ubuntu:java")

puts "JAVA FIXED"