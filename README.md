# socketServer
服务器端的 socket
A server demo to test long scoket.
first -> import GCDAsyncSocket.h  GCDAsyncSocket+Extension.h
GCDAsyncSocket.h 
GCDAsyncSocket+Extension.h
then -> change main.m
main.m
add -> ServiceListener.h
ServiceListener.h

In ServiceListener, you need creat a strong link to clientSock, if you don't do that, the clientSocket will be die when it completes to write data. 
