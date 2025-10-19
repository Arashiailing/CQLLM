/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description Detects usage of Python 2's built-in 'input' function which evaluates input as executable code.
 *              This creates arbitrary code execution risks. Unlike 'raw_input()' that safely returns strings,
 *              'input()' in Python 2 interprets input as Python expressions, making it dangerous.
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

// This query identifies dangerous input() function calls in Python 2 code
// by leveraging data flow analysis to track function invocations
from DataFlow::CallCfgNode dangerousInputCall
where
  // Filter for Python 2 environments where input() is unsafe
  major_version() = 2
  // Identify calls to the built-in 'input' function
  and dangerousInputCall = API::builtin("input").getACall()
  // Exclude safe 'raw_input' calls from our results
  and dangerousInputCall != API::builtin("raw_input").getACall()
select dangerousInputCall, "Python 2's 'input()' function evaluates input as code, creating arbitrary execution risks"