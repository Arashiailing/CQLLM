/**
 * @name Improper LDAP Authentication
 * @description A user-controlled query carries no authentication
 * @kind problem
 * @problem.severity warning
 * @id py/improper-ldap-auth
 * @tags security
 *       experimental
 *       external/cwe/cwe-287
 */

// 确定精度的导入语句
import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

// 定义一个谓词函数，用于判断是否存在不当的LDAP认证
predicate authenticatesImproperly(LdapBind ldapBind) {
  // 如果存在从任意None值到ldapBind密码的局部数据流，或者ldapBind没有设置密码，则返回true
  (
    DataFlow::localFlow(DataFlow::exprNode(any(None noneName)), ldapBind.getPassword()) or
    not exists(ldapBind.getPassword())
  )
  // 或者存在一个空字符串，并且存在从该空字符串到ldapBind密码的局部数据流，则返回true
  or
  exists(StringLiteral emptyString |
    emptyString.getText() = "" and
    DataFlow::localFlow(DataFlow::exprNode(emptyString), ldapBind.getPassword())
  )
}

// 查询所有不当的LDAP绑定操作
from LdapBind ldapBind
where authenticatesImproperly(ldapBind)
select ldapBind, "The following LDAP bind operation is executed without authentication."
