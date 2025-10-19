/**
 * @name Insecure temporary file
 * @description Detects usage of deprecated temporary file creation methods that may be insecure.
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

// Define an API node representing insecure temporary file creation functions
API::Node insecureTempFileFunction(string moduleName, string funcName) {
  // Check if the module and function match known insecure tempfile functions
  (
    moduleName = "tempfile" and funcName = "mktemp"
    or
    moduleName = "os" and
    (
      funcName = "tmpnam"
      or
      funcName = "tempnam"
    )
  ) and
  // Retrieve the function node from the specified module
  result = API::moduleImport(moduleName).getMember(funcName)
}

// Find all calls to insecure temporary file functions
from Call callNode, string moduleName, string funcName
// Ensure the call matches one of our identified insecure functions
where insecureTempFileFunction(moduleName, funcName).getACall().asExpr() = callNode
// Report the insecure call with a descriptive message
select callNode, "Call to deprecated function " + moduleName + "." + funcName + " may be insecure."