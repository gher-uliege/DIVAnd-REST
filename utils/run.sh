#!/bin/bash

# not set by supervisor
# http://supervisord.org/configuration.html#program-x-section-settings
export USER=$(whoami)
export HOME=/home/$USER

exec julia --procs 2 --eval 'include(joinpath("src","DIVAndREST.jl")); sleep(1000000000)'
