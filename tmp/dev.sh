#!/bin/bash

echo "${@:2}"

v="onetwothree"


grep -Po "[a-zA-Z]"<<<"$v"
