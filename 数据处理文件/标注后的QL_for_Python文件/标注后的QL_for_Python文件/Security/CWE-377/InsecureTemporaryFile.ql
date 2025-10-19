/**
 * @name Insecure temporary file
 * @description Creating a temporary file using this method may be insecure.
 * @kind problem
 * @id py/insecure-temporary-file
 * @problem.severity error
 * @security-severity 7.0
 * @sub-severity high
 * @precision high
 * @tags external/cwe/cwe-377
 *       security
 */

import python
import semmle.python.ApiGraphs

// 定义一个名为 temporary_name_function 的 API::Node 函数，用于检测不安全的临时文件创建方法。
API::Node temporary_name_function(string mod, string function) {
  // 检查模块和函数名是否匹配 tempfile.mktemp 或 os.tmpnam 或 os.tempnam。
  (
    mod = "tempfile" and function = "mktemp"
    or
    mod = "os" and
    (
      function = "tmpnam"
      or
      function = "tempnam"
    )
  ) and
  // 获取指定模块中的指定成员函数。
  result = API::moduleImport(mod).getMember(function)
}

// 从调用节点 c 和字符串 mod、function 中选择数据。
from Call c, string mod, string function
// 条件是 temporary_name_function 返回的调用表达式与当前调用节点 c 相等。
where temporary_name_function(mod, function).getACall().asExpr() = c
// 选择调用节点 c，并生成警告信息，指出调用了可能不安全的已弃用函数。
select c, "Call to deprecated function " + mod + "." + function + " may be insecure."
