#!/usr/bin/env python
"""
Very simple HTTP server in python.
Usage::
    ./dummy-web-server.py [<port>]
Send a GET request::
    curl http://localhost
Send a HEAD request::
    curl -I http://localhost
Send a POST request::
    curl -d "foo=bar&bin=baz" http://localhost
"""
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
from time import time, strftime
import SocketServer

log = "/tmp/qrator_mock.log"
class S(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()

    def do_GET(self):
        self._set_headers()
        self.wfile.write("{}")

    def do_HEAD(self):
        self._set_headers()
        
    def do_POST(self):
        # Doesn't do anything with posted data
        len = self.headers["content-length"] if "content-length" in self.headers else 0
        token = self.headers["x-qrator-auth"] if "x-qrator-auth" in self.headers else None
#        for h in self.headers:
#          if h=="content-length":
#            len = self.headers["content-length"]
#        print(strftime("%Y-%m-%d %H:%M:%S"))
        data = self.rfile.read(int(len))
        self.rfile.close()
        l = open(log, 'a')
        l.write("%s method:%s uri:%s token:%s body:%s\n" % ( strftime("%Y-%m-%d %H:%M:%S"), self.command, self.path, token, data) )
        l.close
        self._set_headers()
        self.wfile.write('{"result":"Successful","error":null,"id":1}')
        
def run(server_class=HTTPServer, handler_class=S, port=8015):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print 'Starting httpd...'
    httpd.serve_forever()

if __name__ == "__main__":
    from sys import argv

    if len(argv) >= 3:
        log = argv[2]
    if len(argv) >= 2:
        run(port=int(argv[1]))
run()
