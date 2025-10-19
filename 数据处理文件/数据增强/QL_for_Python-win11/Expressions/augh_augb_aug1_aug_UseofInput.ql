/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description This query identifies dangerous uses of the built-in 'input' function in Python 2 code.
 *              The 'input()' function in Python 2 evaluates user input as Python code, creating a
 *              critical code injection vulnerability. This is different from 'raw_input()',
 *              which safely returns user input as a string without any evaluation.
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

// Find all vulnerable input function calls in Python 2 codebases
from DataFlow::CallCfgNode unsafeInputUsage
where
  // Restrict analysis to Python 2 environments
  major_version() = 2
  and
  // Match calls to the unsafe 'input' builtin function
  unsafeInputUsage = API::builtin("input").getACall()
  and
  // Exclude safe 'raw_input' calls from the results
  unsafeInputUsage != API::builtin("raw_input").getACall()
select unsafeInputUsage, "The unsafe built-in function 'input' is used in Python 2, which can lead to code injection."