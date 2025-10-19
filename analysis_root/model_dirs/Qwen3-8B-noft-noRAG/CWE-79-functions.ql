import python

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/functions
 */

from InputParameter, Call
where 
  InputParameter.getSource().getKind() = "http_request" and
  InputParameter.getValue() = Call.getArgument(0) and
  Call.getMethodName() in ("print", "sys.stdout.write", "send", "render_template") and
  Call.getCallee() is Function and
  not (Call.getLocation().getFile() like "%escape%" or Call.getLocation().getFile() like "%html_escape%")
select Call.getLocation(), "Potential reflected XSS: user input is directly output without escaping"