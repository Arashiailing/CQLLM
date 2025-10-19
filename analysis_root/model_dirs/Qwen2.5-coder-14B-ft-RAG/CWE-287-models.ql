/**
 * @name CWE-287: Improper Authentication
 * @description When an actor claims to have a given identity, the product does not prove or insufficiently proves that the claim is correct.
 * @kind problem
 * @tags security
 *       quality
 *       external/cwe/cwe-287
 * @problem.severity error
 * @sub-severity high
 * @precision medium
 * @id py/models
 */

import python
import LdapSecurity

from BindStatement bindstmt
where auth_not_proven(bindstmt)
select bindstmt, "Binding without proper authentication."