/**
 * @name Insecure temporary file creation
 * @description Detects usage of deprecated temporary file creation methods that
 *              may lead to security vulnerabilities due to predictable file names.
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
API::Node insecureTempFileCreationMethod(string sourceModule, string targetFunction) {
  exists(string moduleRef, string functionRef |
    // Define conditions for insecure temporary file methods
    (
      // Check for tempfile.mktemp function
      moduleRef = "tempfile" and functionRef = "mktemp"
      or
      // Check for os.tmpnam or os.tempnam functions
      moduleRef = "os" and
      (
        functionRef = "tmpnam"
        or
        functionRef = "tempnam"
      )
    ) and
    // Bind the module and function names to the predicate parameters
    sourceModule = moduleRef and
    targetFunction = functionRef and
    // Retrieve the API node for the specified module member
    result = API::moduleImport(moduleRef).getMember(functionRef)
  )
}

// Main query to find calls to insecure temporary file methods
from Call functionCall, string sourceModule, string targetFunction
where 
  // Match calls to any of the insecure temporary file methods
  insecureTempFileCreationMethod(sourceModule, targetFunction).getACall().asExpr() = functionCall
select 
  functionCall, 
  "Call to deprecated function " + sourceModule + "." + targetFunction + " may be insecure."