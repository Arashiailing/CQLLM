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
 * Identifies API nodes representing insecure temporary file creation methods.
 * This predicate checks for deprecated functions that create temporary files
 * in an insecure manner by using predictable file names.
 */
API::Node insecureTempFileMethod(string moduleName, string methodName) {
  exists(string mod, string func |
    (
      // Check for tempfile.mktemp function
      mod = "tempfile" and func = "mktemp"
      or
      // Check for os.tmpnam or os.tempnam functions
      mod = "os" and
      (
        func = "tmpnam"
        or
        func = "tempnam"
      )
    ) and
    // Bind the module and method names to the predicate parameters
    moduleName = mod and
    methodName = func and
    // Retrieve the API node for the specified module member
    result = API::moduleImport(mod).getMember(func)
  )
}

// Main query to find calls to insecure temporary file methods
from Call callNode, string moduleName, string methodName
where 
  // Match calls to any of the insecure temporary file methods
  insecureTempFileMethod(moduleName, methodName).getACall().asExpr() = callNode
select 
  callNode, 
  "Call to deprecated function " + moduleName + "." + methodName + " may be insecure."