/**
 * @name Insecure temporary file
 * @description Identifies usage of deprecated functions for creating temporary files,
 *              which can introduce security risks due to predictable file names.
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
 * Locates API nodes for functions that generate temporary files in an insecure way.
 * These functions are flagged as unsafe because they generate predictable temporary file names
 * that could result in race conditions or other security issues.
 * 
 * @param sourceModule - The name of the module containing the vulnerable function
 * @param targetFunction - The name of the vulnerable function
 * @returns An API node representing the insecure temporary file creation function
 */
API::Node vulnerableTempFileApi(string sourceModule, string targetFunction) {
  // Verify if the module and function combination matches a known insecure temporary file function
  (
    // Scenario 1: Using tempfile.mktemp function
    (sourceModule = "tempfile" and targetFunction = "mktemp")
    or
    // Scenario 2: Using os.tmpnam function
    (sourceModule = "os" and targetFunction = "tmpnam")
    or
    // Scenario 3: Using os.tempnam function
    (sourceModule = "os" and targetFunction = "tempnam")
  ) and
  // Resolve the module and retrieve the specified function member
  result = API::moduleImport(sourceModule).getMember(targetFunction)
}

/**
 * Primary detection logic for identifying calls to insecure temporary file creation functions.
 * This query identifies all locations where potentially insecure temporary file functions are invoked.
 */
from Call vulnerableCallSite, string sourceModule, string targetFunction
where 
  // Determine if the call site corresponds to a known insecure temporary file function
  vulnerableTempFileApi(sourceModule, targetFunction).getACall().asExpr() = vulnerableCallSite
// Output the identified vulnerable call node with an appropriate security warning
select vulnerableCallSite, "Call to deprecated function " + sourceModule + "." + targetFunction + " may be insecure."