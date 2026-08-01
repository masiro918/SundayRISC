from tcpip_proxy import TCPIPProxy

# Put your http payload into http variable

http = b"""GET /something?foo=bar HTTP/1.1
Host: set_host_here.something
"""

# Set real parameters

proxy=TCPIPProxy("127.0.0.1", 8000, "192.168.1.1", 9999)
frame = proxy.create_frame("127.0.0.1", "127.0.0.1", http)

for b in frame:
    print(b, end=', ')
print("13, 10, 13, 10")
print()

print("utf-8 encoded:")

for b in frame:
    print(chr(int(b)), end='')
print()
