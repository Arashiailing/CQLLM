/**
 * @name Insecure temporary file
 * @description Identifies deprecated temporary file creation methods that introduce security risks.
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

// Define API nodes for insecure temporary file creation functions
API::Node insecureTempFileFunction(string modName, string fnName) {
  // Match known insecure tempfile functions by module and name
  (
    modName = "tempfile" and fnName = "mktemp"
    or
    modName = "os" and
    (
      fnName = "tmpnam"
      or
      fnName = "tempnam"
    )
  ) and
  // Retrieve the corresponding function node from the module
  result = API::moduleImport(modName).getMember(fnName)
}

// Identify all calls to insecure temporary file functions
from Call insecureCall, string modName, string fnName
// Ensure the call targets one of the identified insecure functions
where insecureTempFileFunction(modName, fnName).getACall().asExpr() = insecureCall
// Report the insecure call with detailed context
select insecureCall, 
       "Use of deprecated function " + modName + "." + fnName + 
       " creates security vulnerability in temporary file handling"