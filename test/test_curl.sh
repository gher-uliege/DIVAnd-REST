
#PORT=8001

PORT=8002
baseurl="http://127.0.0.1:${PORT}"
tmpfile=/tmp/tmp_DIVAnd.$$


echo "Upload json configuration"
curl --silent --dump-header header.txt --header "Content-Type: application/json" --data @test_analysis2.json "$baseurl/v1/analysis"

# change line endings
tr -d '\15\32' < header.txt > header2.txt

LOCATION=$(awk  '/Location/ { print $2 }'  header2.txt)
echo "Extract queue location: $LOCATION"

FILENAME=out.nc

rm "$FILENAME"

while true; do
    echo "Check if DIVAnd is done"
    curl --silent "$baseurl$LOCATION" > tmpfile
    cat tmpfile
    status=$(jq -r .status < tmpfile)
    if [ "$status" == "done" ]; then
        echo "$ok"
        break
    fi
    sleep 3
done

url=$(jq -r .url < tmpfile)

curl --out "$FILENAME" --silent  "$baseurl$url"
