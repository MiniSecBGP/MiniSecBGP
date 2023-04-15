#!/bin/bash

source venv/bin/activate
BUILD_DIR=$(pwd)
pip3 install -e ".[testing]"
pserve minisecbgp.ini --reload
