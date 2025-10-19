</think>

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.Concepts

/**
 * 用于判断LDAP绑定操作是否使用了不安全的认证方式
 * 不安全的认证方式包括：密码为None或密码来自局部数据流
 * @param ldapBind LDAP绑定操作
 */

predicate authenticatesImproperly(LdapBind ldapBind) {
  // 如果存在从任意None值到ldapBind密码的局部数据流，或者ldapBind没有设置密码，则认为认证方式不安全
  (
    exists(DataFlow::LocalFlowNode none | none.asExpr() instanceof None and
      DataFlow::localFlowPath(none, ldapBind.getPassword())
    )
    or
    not exists(ldapBind.getPassword())
  )
}

// 从LdapBind类中选择所有使用了不安全认证方式的实例
from LdapBind ldapBind
where authenticatesImproperly(ldapBind)
select ldapBind, "LDAP bind using untrusted password."