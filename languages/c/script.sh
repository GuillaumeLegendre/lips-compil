#!/bin/bash

timeout -k 5 -s 9 5 (gcc ./compil/code/code.c -o ./compil/code/code && /compil/code/code )
