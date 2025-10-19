/**
 * @name Insecure temporary file
 * @description Detects the use of deprecated functions for creating temporary files, 
 *              which may lead to security vulnerabilities due to predictable file names.
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
 * Identifies API nodes for functions that create temporary files in an insecure manner.
 * These functions are considered unsafe because they create predictable temporary file names
 * that could lead to race conditions or other security vulnerabilities.
 * 
 * @param moduleName - The name of the module containing the insecure function
 * @param funcName - The name of the insecure function
 * @returns An API node representing the insecure temporary file creation function
 */
API::Node insecureTempFileFunction(string moduleName, string funcName) {
  // Check if the module and function combination represents an insecure temporary file function
  (
    // Case 1: tempfile.mktemp function
    (moduleName = "tempfile" and funcName = "mktemp")
    or
    // Case 2: os.tmpnam function
    (moduleName = "os" and funcName = "tmpnam")
    or
    // Case 3: os.tempnam function
    (moduleName = "os" and funcName = "tempnam")
  ) and
  // Resolve the module and get the specified function member
  result = API::moduleImport(moduleName).getMember(funcName)
}

/**
 * Main query to detect calls to insecure temporary file creation functions.
 * Finds all call sites where a potentially insecure temporary file function is used.
 */
from Call insecureCall, string moduleName, string funcName
where 
  // Check if the call corresponds to an insecure temporary file function
  insecureTempFileFunction(moduleName, funcName).getACall().asExpr() = insecureCall
// Select the problematic call node with an appropriate warning message
select insecureCall, "Call to deprecated function " + moduleName + "." + funcName + " may be insecure."