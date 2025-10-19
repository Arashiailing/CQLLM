import python

/**
 * This query detects potential Command Injection vulnerabilities in Python code.
 * CWE-20: Improper Input Validation
 */

from ProcessBuilder pb, StringLiteral sl
where pb.getCommand() = sl
select pb, "Potentially vulnerable to command injection due to improper input validation."