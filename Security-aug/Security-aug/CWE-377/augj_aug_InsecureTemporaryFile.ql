/**
 * @name Insecure temporary file
 * @description Identifies usage of outdated temporary file generation methods that could lead to security vulnerabilities.
 * @kind problem
 * @id py/insecure-temporary-file
 * @problem.severity error
 * @security-severity 7.0
 * @sub-severity high
 * @precision high
 * @tags external/cwe/cwe-377
 *       security
 */

import python
import semmle.python.ApiGraphs

// Represents an API node for vulnerable temporary file creation methods
API::Node vulnerableTempFileMethod(string libName, string methodName) {
  // Identify if the library and method correspond to known vulnerable tempfile functions
  (
    libName = "tempfile" and methodName = "mktemp"
    or
    libName = "os" and
    (
      methodName = "tmpnam"
      or
      methodName = "tempnam"
    )
  ) and
  // Fetch the method node from the specified library
  result = API::moduleImport(libName).getMember(methodName)
}

// Locate all invocations of vulnerable temporary file methods
from Call functionCall, string libName, string methodName
// Verify that the call corresponds to one of our identified vulnerable methods
where vulnerableTempFileMethod(libName, methodName).getACall().asExpr() = functionCall
// Flag the vulnerable call with an informative alert
select functionCall, "Call to deprecated function " + libName + "." + methodName + " may be insecure."