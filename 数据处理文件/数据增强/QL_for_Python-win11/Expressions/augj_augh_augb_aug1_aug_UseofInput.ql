/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description Detects dangerous uses of the built-in 'input' function in Python 2 code.
 *              The 'input()' function in Python 2 evaluates user input as executable Python code,
 *              creating a critical code injection vulnerability. This contrasts with 'raw_input()',
 *              which safely returns user input as a string without evaluation.
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

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// Identify vulnerable input function calls in Python 2 codebases
from DataFlow::CallCfgNode dangerousInputCall
where
  // Target Python 2 environments exclusively
  major_version() = 2
  and
  // Match calls to the unsafe 'input' builtin function
  dangerousInputCall = API::builtin("input").getACall()
  and
  // Exclude safe 'raw_input' calls from results
  dangerousInputCall != API::builtin("raw_input").getACall()
select dangerousInputCall, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."