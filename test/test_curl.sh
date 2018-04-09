
curl -s --dump-header header.txt --header "Content-Type: application/json" --data @test_analysis2.json http://127.0.0.1:8002/v1/analysis

tr -d '\15\32' < header.txt > header2.txt

LOCATION=$(awk  '/Location/ { print $2 }'  header2.txt)

FILENAME=out.nc

rm "$FILENAME"

while [ ! -s "$FILENAME" ]; do    
    curl -o "$FILENAME" --verbose "http://127.0.0.1:8002$LOCATION"
    sleep 1
done

echo "Result downloaded"

ls -l "$FILENAME"
