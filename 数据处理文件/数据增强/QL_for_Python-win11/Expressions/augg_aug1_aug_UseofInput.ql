/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description Detects invocations of the built-in 'input' function in Python 2 scripts.
 *              Python 2's 'input()' function interprets user input as executable Python code,
 *              introducing a critical code injection risk. This contrasts with 'raw_input()',
 *              which handles user input securely by returning it as an unevaluated string.
 * @kind problem
 * @tags security
 *       correctness
 *       security/cwe/cwe-94
 *       security/cwe/cwe-95
 * @problem.severity error
 * @security-severity 9.8
 * @sub-severity high
 * @precision high
 * @id py/use-of-input
 */

import python  // Import the Python library for analyzing Python code
import semmle.python.dataflow.new.DataFlow  // Import data flow analysis library
import semmle.python.ApiGraphs  // Import API graph analysis library

// Define a variable to represent calls to the built-in 'input' function
from DataFlow::CallCfgNode dangerousInputInvocation
where
  // Ensure the code is written for Python 2
  major_version() = 2
  and
  // Identify calls to the built-in 'input' function, excluding 'raw_input' which is safe
  dangerousInputInvocation = API::builtin("input").getACall()
  and
  dangerousInputInvocation != API::builtin("raw_input").getACall()
select dangerousInputInvocation, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."