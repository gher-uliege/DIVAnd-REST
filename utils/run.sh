#!/bin/bash

exec julia --eval 'include(joinpath("src","DIVAndREST.jl"))'
