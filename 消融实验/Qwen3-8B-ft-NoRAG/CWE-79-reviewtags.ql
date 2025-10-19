import py

from PyCall c, PyString s
where c.getArgValue() is a parameter from HTTP request
  and s is a string that contains the parameter
select s, "Reflected XSS vulnerability"