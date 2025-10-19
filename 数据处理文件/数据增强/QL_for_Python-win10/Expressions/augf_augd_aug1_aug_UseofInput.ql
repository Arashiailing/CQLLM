/**
 * @name Potentially unsafe 'input' function usage in Python 2
 * @description Detects calls to Python 2's built-in 'input' function which evaluates
 *              user input as executable code, creating a critical code injection risk.
 *              This contrasts with 'raw_input()' which safely returns input as a string.
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

// Identify dangerous input() calls in Python 2 environments
from DataFlow::CallCfgNode unsafeInputCall
where
  // Target Python 2 where input() is inherently unsafe
  major_version() = 2
  and
  // Match calls to the vulnerable built-in input function
  unsafeInputCall = API::builtin("input").getACall()
  and
  // Exclude safe raw_input() calls from results
  unsafeInputCall != API::builtin("raw_input").getACall()
select unsafeInputCall, "Use of unsafe built-in 'input' in Python 2 enables code injection."