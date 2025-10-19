/**
* @name Unrestricted file scheme access
* @kind problem
* @id py/filescheme
* @problem.severity error
* @security-severity 7.8
* @precision medium
* @tags external/cwe/cwe-200
*/

import python
import semmle.python.ApiGraphs

// 此查询查找不安全的文件访问操作：
// - 避免了绝对路径引用
// - 避免了显式引用文件系统根目录
// 允许的操作包括但不限于以下情况：
// open("/etc/passwd")
// os.remove("data.txt")

from DataFlow::CallCfgNode func, string paramText
where
  (
    func = API::moduleImport("os").getMember("remove").getACall() and
    paramText = "first argument"
  )
  or
  (
    func = API::moduleImport("os").getMember("unlink").getACall() and
    paramText = "first argument"
  )
  or
  (
    func = API::moduleImport("os").getMember("chmod").getACall() and
    paramText = "first argument"
  )
  or
  (
    func = API::moduleImport("os").getMember("chown").getACall() and
    paramText = "first argument"
  )
  or
  (
    func = API::moduleImport("os").getMember("link").getACall() and
    paramText = "first argument"
  )
  or
  (
    func = API::moduleImport("os").getMember("link").getACall() and
    paramText = "second argument"
  )
  or
  (
    func = API::moduleImport("os").getMember("symlink").getACall() and
    paramText = "first argument"
  )
  or
  (
    func = API::moduleImport("os").getMember("symlink").getACall() and
    paramText = "second argument"
  )
  or
  (
    func = API::moduleImport("open").getReturn().getACall() and
    paramText = "first argument"
  )
select func.asExpr(),
  "Call to " + func.toString() + " specifies a relative path in its " + paramText + "."