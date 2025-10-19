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
API::Node insecureTempFileFunction(string modName, string funcName) {
  // Check if the function is from the tempfile module and is mktemp
  (modName = "tempfile" and funcName = "mktemp" and
   result = API::moduleImport(modName).getMember(funcName))
  or
  // Check if the function is from the os module and is either tmpnam or tempnam
  (modName = "os" and
   (funcName = "tmpnam" or funcName = "tempnam") and
   result = API::moduleImport(modName).getMember(funcName)
  )
}

// Identify all calls to insecure temporary file functions
from Call insecureCall, string modName, string funcName
// Get the insecure API node and check if the call targets it
where insecureTempFileFunction(modName, funcName).getACall().asExpr() = insecureCall
// Report the insecure call with detailed context
select insecureCall, 
       "Use of deprecated function " + modName + "." + funcName + 
       " creates security vulnerability in temporary file handling"