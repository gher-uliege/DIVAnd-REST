
# Install with Docker

Deploy

```
docker pull abarth/divand_rest
docker run --detach --name=divand_rest_container -it -p 8002:8002 abarth/divand_rest
```

Run `docker rm divand_rest_container` if the container already exists.

Test with

```
git clone https://github.com/gher-ulg/DIVAnd-REST.git
cd test
./test_bathymetry_curl.sh
./test_curl.sh # takes some time (~ minutes)
```

Open http://localhost:8002/ in your web browser, for the web user interface.


# Debugging

Inspect logs with:

```
docker logs divand_rest_container
```
