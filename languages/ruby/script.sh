#!/bin/bash

( ruby ./compil/code/code.rb ) & sleep 5 ; echo "timeout">&2;kill $!