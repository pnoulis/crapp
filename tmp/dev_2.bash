#!/bin/bash


# pollute the environment
POLLUTED="yes indeed"

# Run a process that does not inherit the current environment
clean_environment=$(bash --login -c 'set -o posix; set | sort')

# Run a process that will inherit the current environment
dirty_environment=$(set -o posix; unset clean_environment; set | sort | uniq)

# Verify clean environment is clean
echo "$clean_environment" | grep -Po 'POLLUTED' | while :; do
    read -r pollution
    printf %s%s\\n 'clean environment: ' ${pollution:-'Not polluted'} >/dev/null
    break
done

# Verify dirty environment is dirty
echo "$dirty_environment" | grep -Po 'POLLUTED' | while :; do
    read -r pollution
    printf %s%s\\n 'dirty environment: ' ${pollution:-'Not polluted'} >/dev/null
    break
done

# Find difference between polluted and not polluted environment
echo ----------------------------------------------------
echo "$dirty_environment"
echo ----------------------------------------------------
echo ----------------------------------------------------
echo ----------------------------------------------------
echo ----------------------------------------------------
echo ----------------------------------------------------
echo "$clean_environment"
# diff <(echo "dirty_environment") <(echo "$clean_environment") | grep -Po '\w+=.*$'
