# SOME IMPORTANT HEADER

### Variant: A6B8

## How to install 
Bring all the files in the folder to the VM home directory.
Run ```sudo chmod +x configureSystem.sh``` and then run the script.
That's it, you can connect to the server via browser and default port 80.

## How to use
Run ```hostname -I``` to obtain VM IP
Open any browser and paste next to the search line: ```http://<VM IP>:80```
Also you can try ```http://<VM IP>:10000``` to ensure this one port is blocked

## How it works and how it was implemented

**index.html** - there is default page. There is an image in base64 format.

**error.html** - similar to previous one page but with 404 error.

**proxyServer.sh** - the file which acts like a proxy. It performs some calculations and based on them make a *curl* request to localhost:10000 (since *:10000 is available only for localhost)

**proxyServer.service** - the file which is responsible for running the *proxyServer.sh* on port 80. Nothing interesting.

**configureSystem.sh** - the file which is installing all dependencies, moving default ports by modifying */etc/apache2/sites-available/000-default.conf* and */etc/apache2/ports.conf* and also managing proxy files in the system. 
