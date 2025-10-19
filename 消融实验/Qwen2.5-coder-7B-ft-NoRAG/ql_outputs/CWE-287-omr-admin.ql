import python
import experimental.semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

predicate authenticatesImproperly(LdapBind ldapBind) {
  exists(
    DataFlow::Node node |
    node = ldapBind.getPassword() and
    node.getASuperType() = ClassValue::string()
  )
}

from LdapBind ldapBind
where authenticatesImproperly(ldapBind)
select ldapBind, "Improper LDAP Authentication: Password handling is insecure."