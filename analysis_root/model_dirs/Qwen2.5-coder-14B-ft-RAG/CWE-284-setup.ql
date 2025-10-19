/**
 * @deprecated
 * @name CWE-284: Improper Access Control
 * @kind problem
 * @id py/setup
 * @problem.severity error
 * @security-severity 7.8
 */

import python
import semmle.python.ApiGraphs

predicate has_side_effect(API::Node f) {
  f.(Function).getBody() instanceof FunctionBody and not f = API::moduleImport("os").getMember("chmod")
}

predicate has_unsafe_permissions(API::Node f) {
  exists(string mode | mode = "w" or mode = "a" |
    f.(Function).getName() = "open" and
    (
      exists(f.getArg(1), f.getArg(2)) and
      f.getArg(1).(StringLiteral).getText() = mode and
      not f.getArg(2).(IntegerLiteral).getValue() % 2 = 0
    )
  )
}

predicate temporary_name_function(string mod, string function) {
  (mod = "tempfile" and function = "mkstemp") or
  (mod = "tempfile" and function = "mkdtemp") or
  (mod = "tempfile" and function = "NamedTemporaryFile") or
  (mod = "shutil" and function = "copyfileobj") or
  (mod = "zipfile" and function = "ZipFile") or
  (mod = "tarfile" and function = "TarFile") or
  (mod = "gzip" and function = "GzipFile") or
  (mod = "bz2" and function = "BZ2File") or
  (mod = "lzma" and function = "LZMAFile")
}

predicate temporary_name_call(Call c, string mod, string function) {
  temporary_name_function(mod, function) and
  c.getFunc().(Attribute).getName() = function and
  c.getAnArg() = API::moduleImport(mod).getMember(function).getReturn()
}

from Call c, string mod, string function
where temporary_name_call(c, mod, function)
select c, "Use of unsafe temporary file function " + mod + "." + function + "."