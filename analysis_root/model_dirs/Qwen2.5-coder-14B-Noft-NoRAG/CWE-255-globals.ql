import python

/**
 * @name CWE-255: Cleartext Storage of Sensitive Information
 * @description Detects the storage of sensitive information in cleartext.
 * @id py/globals
 */

from Variable v, StringLiteral s
where v.getName() = "password" and s.getValue().matches(".*password.*")
select v, "Sensitive information (password) is stored in cleartext."