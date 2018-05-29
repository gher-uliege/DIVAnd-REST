#!/bin/bash

#nginx -c /home/abarth/src/DIVAnd-REST/utils/nginx.conf &

exec julia --eval 'include(joinpath("src","DIVAndREST.jl")); sleep(1000000000)'
