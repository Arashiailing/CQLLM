/**
 * @name Insecure temporary file
 * @description Creating a temporary file using this method may be insecure.
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

/**
 * Identifies API nodes for insecure temporary file creation functions.
 * Matches specific function names in the tempfile and os modules.
 */
API::Node insecureTempFileFunction(string moduleName, string funcName) {
  // Match tempfile module functions
  (moduleName = "tempfile" and funcName = "mktemp")
  or
  // Match os module functions
  (moduleName = "os" and 
    (funcName = "tmpnam" or funcName = "tempnam")
  ) and
  // Resolve the API node for the matched module and function
  result = API::moduleImport(moduleName).getMember(funcName)
}

// Identify calls to insecure temporary file functions
from Call callNode, string moduleName, string funcName
// Check if the call matches any insecure function
where insecureTempFileFunction(moduleName, funcName).getACall().asExpr() = callNode
// Report the insecure call with contextual information
select callNode, 
  "Call to deprecated function " + moduleName + "." + funcName + " may be insecure."