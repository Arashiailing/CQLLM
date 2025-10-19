/**
 * @deprecated
 */

import python
import semmle.python.ApiGraphs
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests

from DataFlow::CallCfgNode fn, string func, DataFlow::Node arg, string param
where
  (
    exists(string mod |
      mod = "os.path" and
      fn = API::moduleImport(mod).getMember(func).getACall()
    )
    or
    exists(string mod |
      mod = "pathlib" and
      fn = API::moduleImport(mod).getMember("Path").getReturn().getMember(func).getACall()
    )
    or
    exists(string mod |
      mod = "posixpath" and
      fn = API::moduleImport(mod).getMember(func).getACall()
    )
    or
    exists(string mod |
      mod = "ntpath" and
      fn = API::moduleImport(mod).getMember(func).getACall()
    )
  ) and
  not Tests::testCode(fn.getLocation()) and
  (
    (
      (func = "realpath" or func = "relpath") and
      arg = any(DataFlow::Node node | node.asExpr().(Name).getId() = "curdir") and
      param = "start"
    )
    or
    (
      func = "join" and
      arg = fn.getArg(0)
    )
    or
    (
      func = "abspath" and
      arg = fn.getArg(0)
    )
    or
    (
      func = "exists" and
      arg = fn.getArg(0)
    )
    or
    (
      func = "isfile" and
      arg = fn.getArg(0)
    )
    or
    (
      func = "isdir" and
      arg = fn.getArg(0)
    )
    or
    (
      func = "expanduser" and
      arg = fn.getArg(0)
    )
  )
select fn, "Call to " + func + "(" + param + ") with a $@.", arg, "user-provided value"