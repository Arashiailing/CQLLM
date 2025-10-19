import python

/**
 * @name CWE-444: Inconsistent Interpretation of HTTP Requests
 * @description Detects potential HTTP request/response smuggling vulnerabilities by identifying inconsistent handling of HTTP headers and request bodies.
 */
from method m, Parameter p
where 
    m.name = "http.server.BaseHTTPRequestHandler.handle" or
    m.name = "http.server.SimpleHTTPRequestHandler.do_GET" or
    m.name = "http.server.SimpleHTTPRequestHandler.do_POST"
    and p.type = "bytes" and p.name = "request_body"
select m, "Potential HTTP request smuggling vulnerability due to improper request body handling."