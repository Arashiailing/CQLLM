/**
 * @name CWE-134: Use of Externally-Controlled Format String
 * @description The product uses a function that accepts a format string as an argument, but the format string originates from an external source.
 * @kind problem
 * @id py/format-string
 * @problem.severity error
 * @security-severity 7.8
 * @precision high
 * @tags correctness
 *       security
 *       external/cwe/cwe-134
 */

import python
import semmle.python.ApiGraphs

predicate is_format_vulnerable(Call call, string method) {
  call.getFunc().(Attribute::getName/0) = method and
  call.getScope().(ImportedModule::getImportedModuleName/0) = "os"
}

from Call call, string method
where
  is_format_vulnerable(call, method)
select call, "The string '" + method + "' is formatted with an externally controlled format string."