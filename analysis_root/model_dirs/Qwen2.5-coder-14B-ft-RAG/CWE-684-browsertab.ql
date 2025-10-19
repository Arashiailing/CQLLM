/**
 * @name CWE-684: Incorrect Provision of Specified Functionality
 * @description nan
 * @kind problem
 * @id py/browsertab
 * @problem.severity error
 * @security-severity 7.8
 * @precision medium
 * @tags security
 *       external/cwe/cwe-684
 */

import python
import semmle.python.ApiGraphs

from DataFlow::CallCfgNode call, string module, string function
where
  (
    module = "os" and function = "popen"
    or
    module = "subprocess" and (function = "Popen" or function = "call")
  )
  and call = API::moduleImport(module).getMember(function).getACall()
select call, "The function '" + module + "." + function + "' may not be safe."