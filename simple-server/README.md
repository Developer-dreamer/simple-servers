# Assignment 2 
#### Assignment variant: A3B2


## Implementation details:

During work on this assignment next features were implemented:
1. apiClient.sh - responsible for connection to the server on port 4242. You must provide the default IP to connect when running the client.
2. apiServer.sh - responsible for managing connection on the remote. Reading from input till get "Hi!" from any client, and then proceeds handshake. Almost every action is logged, so you can find the issue if anything goes wrong
3. apiService.service - responsible for managing apiServer.sh on port 4242. 
4. db.txt - database with 32 records about films (always stored in **/home/ubuntu/**)
5. configureServer.sh - responsible for installation of the files and managing dependencies. Also, if needed, install the packages such as socat.

## How to install:

First of all run the following: ``` multipass transfer apiServer.sh apiService.service configureServer.sh db.txt```.
Then, make **configureServer.sh** executable
After this step run the script mentioned above.
That's it, your server is enabled.

## How to use:

Get the IP address of the VM where you script is running.
Make the apiClient executable.
Run ./apiClient.sh <IP of VM>
That's it, type commands and observe the results.
