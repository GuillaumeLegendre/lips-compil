#!/bin/bash

name=`cat` && javac /compil/code/`echo $name`.java && java -classpath /compil/code `echo $name`
