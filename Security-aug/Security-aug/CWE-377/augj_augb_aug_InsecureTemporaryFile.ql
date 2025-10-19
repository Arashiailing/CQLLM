/**
 * @name Insecure temporary file creation
 * @description Identifies the use of deprecated temporary file creation methods that can lead to security vulnerabilities.
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
 * Represents an API node for functions that create temporary files in an insecure manner.
 * These functions are deprecated due to security concerns and should be avoided.
 */
API::Node insecureTempFileApiNode(string moduleName, string funcName) {
  // Match insecure tempfile functions by module and function name
  (
    // Case 1: tempfile.mktemp
    moduleName = "tempfile" and funcName = "mktemp"
    or
    // Case 2: os.tmpnam or os.tempnam
    moduleName = "os" and
    (
      funcName = "tmpnam"
      or
      funcName = "tempnam"
    )
  ) and
  // Retrieve the corresponding API node from the module
  result = API::moduleImport(moduleName).getMember(funcName)
}

// Identify calls to insecure temporary file creation functions
from Call problematicCall, string moduleName, string funcName
where
  // Check if the call corresponds to any identified insecure function
  insecureTempFileApiNode(moduleName, funcName).getACall().asExpr() = problematicCall
// Report the insecure call with contextual security message
select problematicCall, "Call to deprecated function " + moduleName + "." + funcName + " may be insecure."