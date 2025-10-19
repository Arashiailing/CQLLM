/**
* @name CWE-269: Improper Privilege Management
*
@description The product does not properly assign, modify, track,
    or check privileges f
    or an actor, creating an unintended sphere of control f
    or that actor.
*
@id py/catalog
*/
import python
import semmle.python.security.PrivilegeManagement
from PrivilegeManagement::Privilege privilege, Act
    or actor
    where privilege.isAssignedTo(actor)
    select privilege, actor, "Improper privilege management found."