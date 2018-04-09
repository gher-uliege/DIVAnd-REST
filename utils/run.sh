#!/bin/bash

exec julia --eval 'include(joinpath("src","DIVAndREST.jl")); sleep(1000000000)'
