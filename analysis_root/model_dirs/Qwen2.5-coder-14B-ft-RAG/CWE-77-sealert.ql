/**
 * @name CWE-77: Improper Neutralization of Special Elements used in a Command ('Command Injection')
 * @description The product constructs all or part of a command using externally-influenced input from an upstream component, but it does not neutralize or incorrectly neutralizes special elements that could modify the intended command when it is sent to a downstream component.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.3
 * @precision medium
 * @id py/sealert
 * @tags correctness
 *       security
 *       external/cwe/cwe-078
 *       external/cwe/cwe-088
 */

import python
import semmle.python.ApiGraphs

// 根据传入的模块名称和函数名称创建一个API调用节点
private API::Node temporary_name_function(string mod, string function) {
  // 从指定的模块中获取成员函数，并返回其返回类型
  result = API::moduleImport(mod).getMember(function).getReturn()
}

// 从调用节点 c 和字符串 mod、function 中选择数据。
from Call c, string mod, string function
// 条件是 temporary_name_function 返回的调用表达式与当前调用节点 c 相等。
where temporary_name_function(mod, function).getACall().asExpr() = c
// 选择调用节点 c，并生成警告信息，指出调用了可能不安全的已弃用函数。
select c, "Call to deprecated function " + mod + "." + function + " may be insecure."