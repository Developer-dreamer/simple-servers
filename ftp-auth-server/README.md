# Assignment 4

## Description
This is a simple ftp server which allows user to connect to virtual machine based on his credentials.
User must be sure that his credentials added to the server (Ip and password to authenticate IP). After successful authentication you can connect to the VM via ftp protocol and do whatever protocol allows.

## How to install 
To install this you need to add your host machine credentials to the **credentials.txt**. 

For example you need to execute next sequence of the commands:
1. ```ip addr show | grep -w inet | awk '$2 ~ /^10\./ {print $2}' | cut -d'/' -f1```
2. Now you need to add this to the credentials.txt via ```echo "<IP you've just got> <someBeautifulPassword>" > credentials.txt```
3. After this transfer these files to the newly configured VM: ```multipass transfer configureServer.sh authServer.service authServer.sh credentials.txt <yourServer>:/home/ubuntu/```
4. Log in to the VM and run next to commands: ```sudo chmod +x configureServer.sh``` ```./configureServer.sh <list of coma-separated IPs>```

That's all you need to perform.

## How to use 
Now lets try to work with FTP protocol.
If you are using best OS ever (Linux) run the following.

1. ```nc <VM IP> 7777``` (ensure that you have IP of the Virtual machine by running next command inside the VM ```hostname -I```)
2. You will be prompted to enter the password to authenticate in the server. DO THAT!
3. Now press **CTRL + C** and move to the next step.
4. Run the next command ```ftp <VM IP>``` (you probably will need to install the package). After this enter the credentials: **user - ftp_user**, **password - MyFTPPass!**

If there is no messages like **Permission denied or incorrect credentials** everything works as expected and to test it you can run ```ls```. This command must show you 1.txt and 2.txt files each one contains Hello World! message.
Also you can run ```get 1.txt``` -> type quit -> run ```ls -l | grep 1.txt``` and see the file you just downloaded from server. 
