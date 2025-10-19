import python

/**
 * Detects potential CWE-264 (Permissions, Privileges, and Access Controls) issues in Python code.
 */
from Method m
where m.name = "os.system" or m.name = "subprocess.check_output"
select m, "Potential insecure use of system command execution without proper access controls."