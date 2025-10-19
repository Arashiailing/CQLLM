/**
 * @name Detection of unsafe 'input' function in Python 2
 * @description Identifies usage of the built-in 'input' function which, in Python 2, 
 *              can execute arbitrary code provided as input, posing a security risk.
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

import python  // Provides fundamental capabilities for Python language analysis
import semmle.python.dataflow.new.DataFlow  // Enables data flow analysis to trace code execution paths
import semmle.python.ApiGraphs  // Facilitates identification and analysis of standard library function calls

// Identify potentially dangerous invocations of the 'input' function in Python 2 code
from DataFlow::CallCfgNode riskyInputInvocation
where
  // Verify that the code is intended to run in a Python 2 environment
  major_version() = 2
  and
  (
    // Locate calls to the built-in 'input' function, which in Python 2 evaluates
    // the input as Python code, creating a code injection vulnerability
    riskyInputInvocation = API::builtin("input").getACall()
    and
    // Exclude calls to 'raw_input' as it safely treats input as strings in Python 2
    riskyInputInvocation != API::builtin("raw_input").getACall()
  )
select riskyInputInvocation, "The unsafe built-in function 'input' is used in Python 2."  // Report location of unsafe 'input' function usage