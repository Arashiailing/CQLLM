/**
 * @name CWE-203: Observable Discrepancy
 * @id py/websocket
 */
import python
import experimental.semmle.python.security.InsecureRandomness

from InsecureRandomness::Usage usage
where usage.isVulnerable()
select usage, "Potential observable discrepancy due to insecure random number generation."