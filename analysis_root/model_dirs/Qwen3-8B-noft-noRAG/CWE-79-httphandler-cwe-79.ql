import python

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/httphandler-cwe-79
 */

// Find calls to HTTP request parameter getters (e.g., request.args.get)
from Call c
where c.getSelector().getName() = "get"
  and c.getQualifier().getName() = "request"
  and c.getQualifier().getType().getName() = "Request"
  and c.getArgument(0).getValue() = "args"

// Find usages of the retrieved parameter in HTTP responses
from Call c, PathExpression pe
where c.getSelector().getName() = "get"
  and c.getQualifier().getName() = "request"
  and c.getQualifier().getType().getName() = "Request"
  and c.getArgument(0).getValue() = "args"
  and pe.getKind() = "StringLiteral"
  and pe.getStringValue().contains("{{") // Detect template interpolation
  or pe.getStringValue().contains("{") // Detect string formatting
  or pe.getStringValue().contains("$") // Detect f-string
  or pe.getStringValue().contains(".") // Detect attribute access in templates
  and pe.getVariable() = c.getVariable()

select pe, "Potential reflected XSS: User input is directly written to HTTP response."