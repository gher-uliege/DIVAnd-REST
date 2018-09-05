
#PORT=8001

PORT=8002
baseurl="http://127.0.0.1:${PORT}"
tmpfile="/tmp/tmp_DIVAnd.$$"
headerfile="/tmp/tmp_DIVAnd_header.$$"
headerfile2="/tmp/tmp_DIVAnd_header2.$$"


echo "Upload json configuration"
curl --silent --dump-header "$headerfile" --header "Content-Type: application/json" --data @test_analysis2.json "$baseurl/v1/analysis"

# change line endings
tr -d '\15\32' < "$headerfile" > "$headerfile2"

LOCATION=$(awk  '/Location/ { print $2 }'  "$headerfile2")
echo "Extract queue location: $LOCATION"

FILENAME=$(mktemp /tmp/DIVAnd-rest-analysis.XXXXXX)

rm -f "$FILENAME"

while true; do
    #echo "Check if DIVAnd is done"
    curl --silent "$baseurl$LOCATION" > "$tmpfile"
    #cat $tmpfile
    status=$(jq -r .status < "$tmpfile")
    echo "status $status"

    if [ "$status" == "done" ]; then
        echo "$ok"
        break
    fi
    sleep 3
done

url=$(jq -r .url < $tmpfile)

curl --out "$FILENAME" --silent  "$baseurl$url"

if [ -s "$FILENAME" ]; then
    echo "SUCCESS"
else
    echo "FAIL"
fi


rm -f "$FILENAME"
