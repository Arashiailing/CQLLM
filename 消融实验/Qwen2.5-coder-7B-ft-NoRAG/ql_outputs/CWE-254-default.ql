/**
 * @name CWE-254: Default Permissions
 * @description Assigning default permissions that are too permissive can lead to security vulnerabilities.
 * @kind problem
 * @problem.severity warning
 * @security-severity 7.8
 * @precision high
 * @id py/default-permissions
 * @tags security
 */

import python
import semmle.python.security.authorization.DefaultPermissionsQuery

predicate hasDefaultPermissions(string permission) {
  permission = "read" or permission = "write" or permission = "execute"
}

from Authorization author
where hasDefaultPermissions(author.getDefaultPermission())
select author, "Default permission set to '$@'", author.getDefaultPermission()