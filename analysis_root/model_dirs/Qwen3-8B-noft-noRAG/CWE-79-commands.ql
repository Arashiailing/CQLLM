import python

from MethodCall m, Argument arg, StringLiteral str
where 
  m.getName() = "print" or 
  m.getName() = "write" or 
  m.getName() = "send" or 
  m.getDeclaringType().getName() = "werkzeug.wrappers.Response"
  and arg.getValue() = str.getString()
select m.getLocation(), "Potential reflected XSS vulnerability: unescaped user input is directly output in HTML."