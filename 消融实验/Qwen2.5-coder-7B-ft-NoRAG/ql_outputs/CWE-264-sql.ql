/**
 * @name CWE-264: SQL Injection Query
 * @category Permissions, Privileges, and Access Controls
 * @description Using user-controlled inputs in SQL queries without proper validation or escaping can lead to SQL injection vulnerabilities.
 * @id py/sql-injection-query
 */

import python
import semmle.python.security.dataflow.SqlInjectionQuery

from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink
where SqlInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential SQL injection vulnerability due to use of user-controlled input."