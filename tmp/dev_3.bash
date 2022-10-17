#!/usr/bin/env bash

tmp="one:two"

echo ${tmp##*:}
echo ${tmp%%:*}
