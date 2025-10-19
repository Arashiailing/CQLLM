import python

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/htmlserializer
 */

from Method m, Parameter p, Call c
where 
  m.name = "print" or m.name = "write"
  and c.getMethod() = m
  and p.getKind() = "positional"
  and exists (StringLiteral sl | c.getStringLiterals() = sl)
  and not exists (Call call | call.getCallee().getName() = "html.escape" and call.getArgument(0) = p.getValue())
select p.getValue(), "Potential reflected XSS: User input is directly output to HTML without proper escaping"