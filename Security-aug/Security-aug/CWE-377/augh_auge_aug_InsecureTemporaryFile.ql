/**
 * @name Insecure temporary file
 * @description Detects usage of deprecated temporary file creation methods that pose security risks.
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
API::Node insecureTempFileApi(string moduleName, string functionName) {
  // Identify known insecure tempfile functions by their module and name
  (
    moduleName = "tempfile" and functionName = "mktemp"
    or
    moduleName = "os" and
    (
      functionName = "tmpnam"
      or
      functionName = "tempnam"
    )
  ) and
  // Retrieve the corresponding function node from the module
  result = API::moduleImport(moduleName).getMember(functionName)
}

// Identify all calls to insecure temporary file functions
from Call vulnerableCall, string moduleName, string functionName
// Define the insecure API node and check if the call targets it
where insecureTempFileApi(moduleName, functionName).getACall().asExpr() = vulnerableCall
// Report the insecure call with detailed context
select vulnerableCall, 
       "Use of deprecated function " + moduleName + "." + functionName + 
       " creates security vulnerability in temporary file handling"