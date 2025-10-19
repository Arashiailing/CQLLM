import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

predicate authenticatesImproperly(LdapBind ldapBind) {
  ldapBind.getPassword().isNull() or
  exists(DataFlow::Node src | 
    DataFlow::localFlow(src, ldapBind.getPassword()) and
    src.isConstant()
  )
}

from LdapBind ldapBind
where authenticatesImproperly(ldapBind)
select ldapBind, "LDAP bind without proper password verification"