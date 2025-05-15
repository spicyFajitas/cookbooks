# Commands

Commands based on useful packages

## adduser

```shell
# debian - sudo group
# rhel/fedora - wheel group
useradd -m -s /bin/bash -G sudo newUserName
    # -m make home directory at /home/newUserName
    # -s set default shell
    # -G set group
```

## btop

similar to htop

```bash
btop
    # better top
```

## gdu

graphical du command that is really fast

```bash
gdu 
    -x / # do not cross filesystem boundaries, i.e. only count files and directories on the same filesystem as the directory being scanned.
```

## lsof

```bash
lsof
    # lists open files
```

## ncdu

graphical du command that is really fast

```bash
ncdu 
    -x / # do not cross filesystem boundaries, i.e. only count files and directories on the same filesystem as the directory being scanned.
```

## nproc

```bash
nproc
    # number of processors
```

## ssh-keygen

```bash
ssh-keygen
    -t # for type
    -C # for comment
ssh-keygen -t ed25519 -C "username@machine-name"
```
