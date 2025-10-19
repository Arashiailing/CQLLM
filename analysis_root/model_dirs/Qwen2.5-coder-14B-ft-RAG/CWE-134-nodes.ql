/**
 * @name CWE-134: Use of Externally-Controlled Format String
 * @description The product uses a function that accepts a format string as an argument, but the format string originates from an external source.
 * @kind problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/format-string-vulnerability
 * @tags correctness
 *       security
 *       external/cwe/cwe-134
 */

import python
import semmle.python.ApiGraphs

predicate vulnerableFormatString(string mod, string func) {
  exists(API::Module m |
    mod = m.getId() and
    exists(string fmt | 
      (fmt = "%s" or fmt = "%r") and
      exists(API::Node n | 
        n = m.getMember(func).getReturn() and
        n = API::builtin(fmt)
      )
    )
  )
}

predicate vulnerableAddressTuple(API::Node start, string hostname) {
  hostname = "%" and
  start = API::builtin("%")
  or
  hostname = "%" and
  start = API::builtin("(%s, %d)")
  or
  hostname = "%s" and
  start = API::builtin("%s:%d")
}

predicate temporary_name_function(string mod, string function) {
  vulnerableFormatString(mod, function) and
  not mod = "os"
  or
  function = "tempnam" and
  mod = "os"
}