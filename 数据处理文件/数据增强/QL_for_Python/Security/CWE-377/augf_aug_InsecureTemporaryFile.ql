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
API::Node insecureTempFileApiNode(string tempModule, string tempFunc) {
  // Identify modules and functions known to create temporary files insecurely
  (
    // Check for the 'tempfile' module's 'mktemp' function
    tempModule = "tempfile" and tempFunc = "mktemp"
    or
    // Check for the 'os' module's 'tmpnam' or 'tempnam' functions
    tempModule = "os" and
    (
      tempFunc = "tmpnam"
      or
      tempFunc = "tempnam"
    )
  ) and
  // Retrieve the function node from the specified module
  result = API::moduleImport(tempModule).getMember(tempFunc)
}

// Identify all calls to insecure temporary file functions
from Call insecureTempFileCall, string tempModule, string tempFunc
// Ensure the call corresponds to one of the identified insecure functions
where insecureTempFileApiNode(tempModule, tempFunc).getACall().asExpr() = insecureTempFileCall
// Generate an alert for the insecure call with a descriptive message
select insecureTempFileCall, "Call to deprecated function " + tempModule + "." + tempFunc + " may be insecure."