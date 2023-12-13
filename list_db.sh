#!/bin/bash

echo "Already existing databases:"
cd ./data
ls -F | grep / | tr / " "

cd . &> /dev/null
