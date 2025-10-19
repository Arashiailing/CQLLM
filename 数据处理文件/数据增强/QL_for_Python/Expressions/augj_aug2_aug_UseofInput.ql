/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description This query identifies potentially dangerous uses of Python 2's built-in 'input' function.
 *              The 'input()' function in Python 2 evaluates user input as Python expressions, which can lead
 *              to arbitrary code execution vulnerabilities. This is in contrast to 'raw_input()', which safely
 *              returns user input as a string without evaluation. Attackers can exploit this vulnerability
 *              by supplying malicious input that gets executed in the context of the application.
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

// Identify vulnerable input() calls through data flow analysis
from DataFlow::CallCfgNode dangerousInputUsage
where
  // Restrict analysis to Python 2 environments
  major_version() = 2 and
  // Match calls to the built-in 'input' function
  dangerousInputUsage = API::builtin("input").getACall() and
  // Exclude safe 'raw_input' calls from results
  dangerousInputUsage != API::builtin("raw_input").getACall()
select dangerousInputUsage, "Python 2's 'input()' function evaluates input as code, creating arbitrary execution risks"