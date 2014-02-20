#!/bin/bash

( gcc ./compil/code/code.c -o ./compil/code/code && /compil/code/code ) & sleep 5 ; echo "timeout">&2;kill $!
