# bash-scripts
## Table of Contents
- [send.sh](#sendsh)
- [archive_all.sh](#archiveallsh)


## send.sh
### Dependincies
- ssh
- scp
- sshpass
### Description
Uses sshpass and a 'key' to send a file to a remote server.
The key the ssh password encrypted with gpg.
### Key creation
```bash
touch .sshpwd
echo "sshkey" >> .sshpwd
gpg -c .sshpwd
rm .sshpwd
```
#### MAKE SURE TO LEAVE THE KEY IN THE SAME DIRECTORY AS THE SCRIPT!
### Usage
```bash
./send.sh <file> <user@host>:/dir/dir/>
```
If you dont have the dependencies the script will prompt you and install ssh (open ssh) and sshpass if your os is:
- Debian/Ubuntu
- CentOS
- Fedora
- Archlinux ( the best :) )
otherwise it'll exit 1

## archive_all.sh
### Dependincies
- tar
- openssl

### Description
Archives all files in the current directory.
### Usage
```bash
./archive_all.sh [password]
```
the program will get the all images, videos, and txt files in the current directory. and will encrypt the with openssl if wanted.

