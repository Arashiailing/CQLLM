/**
 * @name Python Insecure LDAP Authentication
 * @description Python LDAP Insecure LDAP Authentication
 * @kind path-problem
 * @problem.severity error
 * @id py/insecure-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-522
 *       external/cwe/cwe-523
 */

// 确定精度以上
import python  // 导入Python库
import experimental.semmle.python.security.LdapInsecureAuth  // 导入实验性的Python安全LDAP不安全认证库
import LdapInsecureAuthFlow::PathGraph  // 导入LDAP不安全认证流路径图

from LdapInsecureAuthFlow::PathNode source, LdapInsecureAuthFlow::PathNode sink  // 从源节点和目标节点中选择
where LdapInsecureAuthFlow::flowPath(source, sink)  // 条件：存在从源节点到目标节点的流动路径
select sink.getNode(), source, sink, "This LDAP host is authenticated insecurely."  // 选择目标节点、源节点、目标节点，并返回警告信息“此LDAP主机被不安全地认证。”
