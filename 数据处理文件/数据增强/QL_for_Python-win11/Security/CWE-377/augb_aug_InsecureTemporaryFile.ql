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
API::Node insecureTempFileApiNode(string sourceModule, string targetFunction) {
  // Check if the module and function correspond to known insecure tempfile functions
  (
    sourceModule = "tempfile" and targetFunction = "mktemp"
    or
    sourceModule = "os" and
    (
      targetFunction = "tmpnam"
      or
      targetFunction = "tempnam"
    )
  ) and
  // Retrieve the function node from the specified module
  result = API::moduleImport(sourceModule).getMember(targetFunction)
}

// Identify all calls to insecure temporary file creation functions
from Call insecureCall, string sourceModule, string targetFunction
// Ensure the call corresponds to one of the identified insecure functions
where insecureTempFileApiNode(sourceModule, targetFunction).getACall().asExpr() = insecureCall
// Report the insecure call with a detailed message
select insecureCall, "Call to deprecated function " + sourceModule + "." + targetFunction + " may be insecure."