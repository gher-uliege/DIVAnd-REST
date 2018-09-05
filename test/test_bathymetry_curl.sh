
TEMPFILE=$(mktemp /tmp/DIVAnd-rest-bath.XXXXXX)
curl --out "$TEMPFILE" --silent "http://127.0.0.1:8002/v1/bathymetry/?bbox=-10,30,50,45&resolution=1,1&dataset=GEBCO"

if [ -s "$TEMPFILE" ]; then
    echo "SUCCESS"
else
    echo "FAIL"
fi

rm -f "$TEMPFILE"
