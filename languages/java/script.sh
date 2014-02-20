#!/bin/bash

timeout -k 5 -s 9 5 name=`cat` && javac /compil/code/`echo $name`.java && java -classpath /compil/code `echo $name`
