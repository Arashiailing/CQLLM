import python

from Call call, Argument arg
where 
  call.getDecl().getName() = "flask.redirect" or 
  (call.getDecl().getName() = "http.server.BaseHTTPRequestHandler.send_response" and 
   exists(Header header | header.getName() = "Location"))
  and 
  arg.getValue() is UserInput
select call.getLocation(), "Potential URL redirection using unvalidated user input"