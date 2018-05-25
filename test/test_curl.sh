
#PORT=8001

PORT=8002

echo "Upload json configuration"
curl --silent --dump-header header.txt --header "Content-Type: application/json" --data @test_analysis2.json http://127.0.0.1:${PORT}/v1/analysis

# change line endings
tr -d '\15\32' < header.txt > header2.txt

LOCATION=$(awk  '/Location/ { print $2 }'  header2.txt)
echo "Extract queue location: $LOCATION"

FILENAME=out.nc

rm "$FILENAME"

echo "Check if DIVAnd is done"
curl --out "$FILENAME" --silent "http://127.0.0.1:${PORT}$LOCATION"

while [ ! -s "$FILENAME" ]; do
    sleep 2
    curl --out "$FILENAME" --silent  "http://127.0.0.1:${PORT}$LOCATION"
done

echo "Result downloaded: $FILENAME"
