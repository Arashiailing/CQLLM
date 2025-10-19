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
API::Node insecureTempFileMethod(string targetModule, string targetMethod) {
  exists(string moduleIdentifier, string methodIdentifier |
    // Define insecure module-method combinations
    (
      // Case 1: tempfile.mktemp function
      moduleIdentifier = "tempfile" and methodIdentifier = "mktemp"
      or
      // Case 2: os.tmpnam or os.tempnam functions
      moduleIdentifier = "os" and
      (
        methodIdentifier = "tmpnam"
        or
        methodIdentifier = "tempnam"
      )
    ) and
    // Bind predicate parameters to local variables
    targetModule = moduleIdentifier and
    targetMethod = methodIdentifier and
    // Resolve API node for the identified module member
    result = API::moduleImport(moduleIdentifier).getMember(methodIdentifier)
  )
}

// Main query to find calls to insecure temporary file methods
from Call vulnerableCall, string moduleIdentifier, string methodIdentifier
where 
  // Match calls to any identified insecure temporary file methods
  insecureTempFileMethod(moduleIdentifier, methodIdentifier).getACall().asExpr() = vulnerableCall
select 
  vulnerableCall, 
  "Call to deprecated function " + moduleIdentifier + "." + methodIdentifier + " may be insecure."