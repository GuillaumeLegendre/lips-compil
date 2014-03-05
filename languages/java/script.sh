#!/bin/bash

name=`grep -o -P -m 1 '(?<=class\s)\w+' /compil/code/code.java`
mv /compil/code/code.java /compil/code/`echo $name`.java
javac -encoding UTF-8 /compil/code/`echo $name`.java
java -classpath /compil/code `echo $name`
