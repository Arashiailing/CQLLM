import py
import http

from RequestParameter p, Call c
where p is from http.getRequestParameter()
  and c.getTarget() = http.getResponseContent()
  and c.getArgument(0) = p
select p, "Reflected XSS vulnerability: User input is directly used in HTTP response content."