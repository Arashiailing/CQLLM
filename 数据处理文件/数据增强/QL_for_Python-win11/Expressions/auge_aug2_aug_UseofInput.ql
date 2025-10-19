/**
 * @name Dangerous 'input' function usage in Python 2
 * @description Identifies calls to Python 2's built-in 'input' function that evaluates user input
 *              as executable code, leading to arbitrary code execution vulnerabilities. Unlike
 *              'raw_input()' which safely returns strings, 'input()' in Python 2 interprets input
 *              as Python expressions, creating significant security risks.
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

import python  // Core Python analysis library
import semmle.python.dataflow.new.DataFlow  // Data flow tracking capabilities
import semmle.python.ApiGraphs  // Built-in function API mappings

// Define conditions for identifying dangerous input() function calls
from DataFlow::CallCfgNode dangerousInputInvocation
where
  // Limit analysis scope to Python 2 codebase
  major_version() = 2
  and
  // Identify calls to the built-in 'input' function
  dangerousInputInvocation = API::builtin("input").getACall()
  and
  // Ensure we don't flag 'raw_input' calls which are safe
  dangerousInputInvocation != API::builtin("raw_input").getACall()
select dangerousInputInvocation, "Python 2's 'input()' function evaluates input as code, creating arbitrary execution risks"