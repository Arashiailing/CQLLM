import python
import dataflow

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/base-cwe-79
 */

from method, arg, node
where 
  method.name = "print" or 
  method.name = "sys.stdout.write" or 
  method.name = "flask.Response" and 
  (arg is stringLiteral or arg is variable) and 
  exists (node: Node, node.hasName("request") and node.isGlobal())
select method, "Potential reflected XSS vulnerability: User input is being output directly without sanitization"