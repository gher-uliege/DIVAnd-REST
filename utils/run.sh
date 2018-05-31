#!/bin/bash

#nginx -c /home/abarth/src/DIVAnd-REST/utils/nginx.conf &

# not set by supervisor
# http://supervisord.org/configuration.html#program-x-section-settings
export USER=$(whoami)
export HOME=/home/$USER

exec julia --eval 'include(joinpath("src","DIVAndREST.jl")); sleep(1000000000)'
