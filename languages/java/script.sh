#!/bin/bash

name=`grep -oP '(?<=class\s)\w+' /compil/code/code.java`
mv /compil/code/code.java /compil/code/`echo $name`.java
javac /compil/code/`echo $name`.java
java -classpath /compil/code `echo $name`
