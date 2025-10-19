/**
 * @name CWE-284: Improper Access Control
 * @id py/setup
 */
import python
import semmle.python.security.dataflow.AccessControlCheck

from AccessControlCheck::AccessControlViolation acv
where acv.violationType = "improper_access_control"
select acv, "Potential improper access control vulnerability detected."