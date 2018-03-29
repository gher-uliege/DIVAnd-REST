#!/bin/bash

exec julia --eval 'include(joinpath("src","DIVAndREST.jl")); sleep(10000000)'
