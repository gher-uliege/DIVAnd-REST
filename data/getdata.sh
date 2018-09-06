
if ! [ -f gebco_30sec_16.nc ]; then
    wget -O gebco_30sec_16.nc 'https://b2drop.eudat.eu/s/o0vinoQutAC7eb0/download'
fi

if ! [ -f WOD-Salinity.nc ]; then
    wget -O WOD-Salinity.nc 'http://b2drop.eudat.eu/s/UsF3RyU3xB1UM2o/download'
fi
