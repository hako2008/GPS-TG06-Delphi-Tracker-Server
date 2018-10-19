# GPS-TG06-Delphi-Tracker-Server
this is a delphi project for tracking GPS that use GT06 communication protocol, sense there is few servers for this kind of protocol.

Please note that I have included a PDF manual within this directory.
GPRS protocol, is NOT the manual for specific device but it is for everydevice using GT06. The reason I have included it is because it explains the gprs protocol and messages very well and is useful knowledge.

Actually it's not a complete project it's just a tool that make you understanding GT06 or you can build your own project using this one as reference.

# The use
1. you can just run the EXE in Debug folder tracker\Win32\Debug\Project2.exe, by default using 20488 port, i should warn you, that the GPS devices usually using GPRS so it's not locally connected to your network, so you should give it your public internet ip not your server local ip, if your server connecting to the internet through router you have to pay attention to configure port forwarding to your local machine (server) in the router.
2. for whom familiar with Delphi you can open the project and do what ever you want to do.
