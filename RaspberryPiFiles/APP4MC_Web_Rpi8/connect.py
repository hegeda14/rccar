#!/usr/bin/python
import socket,sys
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
print("Connecting..")
sock.connect((sys.argv[1], 15533))
print("Connected")

msg="hello world"
print("Sending msg: "+msg)
sock.send(msg)

print("Closing...")
sock.close()
print("Closed")
