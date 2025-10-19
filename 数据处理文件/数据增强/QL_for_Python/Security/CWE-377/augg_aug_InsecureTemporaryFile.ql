/**
 * @name Insecure temporary file
 * @description Identifies usage of deprecated temporary file creation methods that pose security risks.
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

// Define API nodes representing deprecated temporary file functions
API::Node getInsecureTempFileFunc(string modName, string funcName) {
  // Match known insecure tempfile functions across modules
  (
    modName = "tempfile" and funcName = "mktemp"
    or
    modName = "os" and
    (
      funcName = "tmpnam"
      or
      funcName = "tempnam"
    )
  ) and
  // Retrieve corresponding API node from module hierarchy
  result = API::moduleImport(modName).getMember(funcName)
}

// Identify all calls to insecure temporary file functions
from Call vulnerableCall, string modName, string funcName
// Ensure the call targets a flagged insecure function
where getInsecureTempFileFunc(modName, funcName).getACall().asExpr() = vulnerableCall
// Report findings with contextual security warning
select vulnerableCall, "Deprecated function " + modName + "." + funcName + " creates insecure temporary files."