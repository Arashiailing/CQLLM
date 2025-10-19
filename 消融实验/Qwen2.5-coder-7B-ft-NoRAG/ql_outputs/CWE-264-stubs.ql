/**
 * @name CWE-264: Permissions, Privileges, and Access Controls
 * @description nan
 * @id py/stubs
 */

import python

class PermissionError extends Exception {
  PermissionError() {
    this.getMessage() = "Permission denied"
  }
}

predicate has_permission(File file, User user) {
  exists(Acl acl | acl.file = file and acl.user = user and acl.granted)
}

from File file, User user
where not has_permission(file, user)
select file, user, "User does not have permission to access this file."