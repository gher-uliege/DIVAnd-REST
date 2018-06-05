
curl --out test.nc --silent "http://127.0.0.1:8002/v1/bathymetry/?bbox=-10,30,50,45&resolution=1,1&dataset=GEBCO"

if [ -s test.nc ]; then
    echo "SUCCESS"
else
    echo "FAIL"
fi
