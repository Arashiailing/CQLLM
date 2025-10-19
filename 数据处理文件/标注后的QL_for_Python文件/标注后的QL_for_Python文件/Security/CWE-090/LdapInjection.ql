/**
 * @name LDAP query built from user-controlled sources
 * @description Building an LDAP query from user-controlled sources is vulnerable to insertion of
 *              malicious LDAP code by the user.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.8
 * @precision high
 * @id py/ldap-injection
 * @tags security
 *       external/cwe/cwe-090
 */

// Determine precision above
import python // 导入Python语言库，用于分析Python代码
import semmle.python.security.dataflow.LdapInjectionQuery // 导入LDAP注入查询相关的数据流分析库
import LdapInjectionFlow::PathGraph // 导入LDAP注入路径图类

from LdapInjectionFlow::PathNode source, LdapInjectionFlow::PathNode sink, string parameterName
where
  // 检查是否存在从source到sink的DN参数的数据流路径
  LdapInjectionDnFlow::flowPath(source.asPathNode1(), sink.asPathNode1()) and
  parameterName = "DN"
  or
  // 检查是否存在从source到sink的filter参数的数据流路径
  LdapInjectionFilterFlow::flowPath(source.asPathNode2(), sink.asPathNode2()) and
  parameterName = "filter"
select sink.getNode(), source, sink,
  // 选择结果包括：sink节点、source节点、sink节点、描述信息、source节点、用户输入值的描述
  "LDAP query parameter (" + parameterName + ") depends on a $@.", source.getNode(),
  "user-provided value"
