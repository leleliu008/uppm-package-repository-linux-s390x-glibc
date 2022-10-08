# uppm-package-repository-linux-s390x-glibc

these packages are linked against [glibc](https://www.gnu.org/software/libc/).

these packages are created by [ppkg](https://github.com/leleliu008/ppkg).

## how to build these packages

**step1. create a docker container**
```
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
docker run --rm -it s390x/ubuntu bash
```

**step2. install curl via system's package manager**
```
apt -y update
apt -y install curl
```

**step3. install ppkg**
```
curl -LO https://raw.githubusercontent.com/leleliu008/ppkg/master/bin/ppkg
chmod a+x ppkg
mv ppkg /usr/local/bin/
ppkg setup --use-system-package-manager
ppkg update
```

**install package via ppkg**
```
ppkg install <PACKAGE-NAME>
```
