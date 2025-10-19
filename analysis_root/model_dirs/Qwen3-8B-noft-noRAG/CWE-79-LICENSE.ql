import python
import semmle.code.java.dataflow.DataFlow

/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/CWE-79
 */

from PyFunctionCall printCall, PyStringLiteral htmlTag, PyStringConcatenate concat, PyVariable var, PyCall getInputCall
where 
  // Find user input from HTTP request parameters
  getInputCall = PyCall.new("request.args.get", [PyStringLiteral.new(".*")])
  
  // Track the variable containing user input
  var = getInputCall.getVariable()
  
  // Check for string concatenation with user input
  concat = PyStringConcatenate.new([htmlTag, var,...], ".*")
  
  // Check for direct output to HTTP response (e.g., print)
  printCall = PyCall.new("print", [concat])
  
  // Ensure that the output is HTML context (e.g., contains < or >)
  htmlTag.getString().matches("<.*>")
select printCall, "Potential reflected XSS: User input is directly concatenated into HTML output"