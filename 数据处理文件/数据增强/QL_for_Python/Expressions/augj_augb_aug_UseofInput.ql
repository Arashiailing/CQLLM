/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description Detects invocations of the built-in 'input' function in Python 2 code.
 *              In Python 2, the 'input()' function evaluates user input as executable Python code,
 *              introducing a severe code injection vulnerability. This contrasts with 'raw_input()',
 *              which safely returns a string without performing any evaluation.
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

// Identify dangerous input function calls in Python 2 code
from DataFlow::CallCfgNode dangerousInputInvocation
where
  // Scope the analysis to Python 2 environments only
  major_version() = 2 and
  // Detect calls to the vulnerable 'input' builtin function
  dangerousInputInvocation = API::builtin("input").getACall() and
  // Ensure we're not matching the safe 'raw_input' alternative
  dangerousInputInvocation != API::builtin("raw_input").getACall()
select dangerousInputInvocation, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."