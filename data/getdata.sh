if ! [ -f gebco_30sec_4.nc ]; then
    wget -O gebco_30sec_4.nc 'https://b2drop.eudat.eu/s/ACcxUEZZi6a4ziR/download'
fi

if ! [ -f gebco_30sec_16.nc ]; then
    wget -O gebco_30sec_16.nc 'https://b2drop.eudat.eu/s/o0vinoQutAC7eb0/download'
fi

if ! [ -f WOD-Salinity.nc ]; then
    wget -O WOD-Salinity.nc 'http://b2drop.eudat.eu/s/UsF3RyU3xB1UM2o/download'
fi

if ! [ -f sample-file.nc ]; then
    wget -O sample-file.nc 'https://b2drop.eudat.eu/s/Sk4zTDTi3tgmetR/download'
fi



