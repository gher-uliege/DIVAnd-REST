if ! [ -f gebco_30sec_4.nc ]; then
    wget -O gebco_30sec_4.nc 'https://dox.ulg.ac.be/index.php/s/RSwm4HPHImdZoQP/download'
fi

if ! [ -f gebco_30sec_16.nc ]; then
    wget -O gebco_30sec_16.nc 'https://dox.ulg.ac.be/index.php/s/U0pqyXhcQrXjEUX/download'
fi

if ! [ -f WOD-Salinity.nc ]; then
    wget -O WOD-Salinity.nc 'https://dox.ulg.ac.be/index.php/s/PztJfSEnc8Cr3XN/download'
fi

if ! [ -f sample-file.nc ]; then
    wget -O sample-file.nc 'https://dox.ulg.ac.be/index.php/s/FosTu5frviI8chW/download'
fi



