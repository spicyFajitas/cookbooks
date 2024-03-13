# Lab7

All documentation is written in markdown format

## Add `niceuser` account to Mail server

```bash
# you have to authenticate to root before you can add a user
sudo su
useradd niceuser
```

## Create `test.txt` file on Backup Server

```bash
# create empty file in `/home/playerone/`
touch test.txt /home/playerone/test.txt
```

## Move `importantstuff.txt` file from Folder1 to Folder2 on Workstation-Desk logged in as the playerone user

- open file explorer
- navigate to FlashDrive (E:)
- you should see folder1 and folder2
- open folder1
- click on `importantstuff` document
- cut file
- navigate to FlashDrive(E:)/folder2
- paste file `importantstuff`
