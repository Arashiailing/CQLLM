import python

from FunctionCall fc
where fc.getQualifiedName() = "email.utils.parseaddr" or 
      fc.getQualifiedName() = "urllib.parse.urlsplit" or 
      fc.getQualifiedName() = "http.server.BaseHTTPRequestHandler.send_response" or 
      fc.getQualifiedName() = "socket.socket.sendall"
select fc, "Potential HTTP header injection due to uncontrolled resource consumption"