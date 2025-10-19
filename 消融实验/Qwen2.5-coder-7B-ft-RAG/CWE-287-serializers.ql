import pythonimport experimental.semmle.python.Conceptsimport semmle.python.dataflow.new.DataFlow// 定义一个谓词函数，用于判断是否存在不当的LDAP认证predicate authenticatesImproperly(LdapBind ldapBind) {  // 如果存在从任意None值到ldapBind密码的局部数据流，或者ldapBind没有设置密码，则返回true  (
    exists(DataFlow::Node passwordSrc |
      passwordSrc.(DataFlow::LocalVarNode).getAFlowNode().flowPathToLocal(passwordSrc,
        ldapBind.getPassword()) and
      passwordSrc.pointsTo(NoneVal::none())
    )
    or
    !ldapBind.getPassword().pointsTo(_)  // 如果ldapBind没有设置密码，则返回true
  )}from LdapBind ldapBindwhere authenticatesImproperly(ldapBind)select ldapBind, "Ldap bind operation without proper authentication."