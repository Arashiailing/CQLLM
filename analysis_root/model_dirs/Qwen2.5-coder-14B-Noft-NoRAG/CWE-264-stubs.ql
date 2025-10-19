import python

/**
 * @name CWE-264: Permissions, Privileges, and Access Controls
 * @description Detects potential issues related to permissions, privileges, and access controls.
 * @id py/stubs
 */

from Function f
where f.getName() = "os.system" or f.getName() = "subprocess.call"
select f, "This function call may lead to privilege escalation or unauthorized access."