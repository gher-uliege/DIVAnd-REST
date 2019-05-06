
# Server configuration

```bash
sudo apt-get install nginx nginx-extras apache2-utils
```

```bash
for i in $(seq 1 50); do
    mkdir -p /tmp/tmpdir/user${i}
done

rm /tmp/htpasswd
touch /tmp/htpasswd
for i in $(seq 1 50); do
   htpasswd -b /tmp/htpasswd user${i} user${i}pw
done


dd if=/dev/urandom of=/tmp/tmpdir/user1/file1.dat  bs=1M count=1
dd if=/dev/urandom of=/tmp/tmpdir/user1/file10.dat  bs=10M count=1
dd if=/dev/urandom of=/tmp/tmpdir/user1/file100.dat  bs=100M count=1
for i in $(seq 2 50); do
   cp /tmp/tmpdir/user1/file1.dat /tmp/tmpdir/user$i/file1.dat;
   cp /tmp/tmpdir/user1/file10.dat /tmp/tmpdir/user$i/file10.dat;
   cp /tmp/tmpdir/user1/file100.dat /tmp/tmpdir/user$i/file100.dat;
done
```

The file `nginx-webdav.conf` is in https://github.com/gher-ulg/DIVAnd-REST/docs
Run nginx as:


```bash
/usr/sbin/nginx -c nginx-webdav.conf
```

# Client

```bash
SERVER=http://localhost:8003/
SERVER=http://192.168.1.45:8003/

# create mount points

for i in $(seq 1 50); do mkdir /tmp/webdav_mnt_$i; done

# mount

for i in $(seq 1 50); do echo "mount user$i"; echo user${i}pw | mount.davfs -o username=user$i $SERVER /tmp/webdav_mnt_$i; done

# stress-test

for i in $(seq 1 50); do (md5sum /tmp/webdav_mnt_$i/file1.dat &); done

# unmount

for i in $(seq 1 50); do umount /tmp/webdav_mnt_$i; done

```

# Conclustion:

* 50 mounts in parallel were possible with mount.davfs on the test system; unclear why mount.davfs with B2DROP is limited to just 2 mount points

