import python
import semmle.python.security.dataflow.SqlInjectionQuery

/**
 * @name CWE-264: SQL Injection
 * @description Detects potential SQL injection vulnerabilities.
 * @id py/sql
 */

from SqlInjectionQuery sqlInjection
select sqlInjection, "This query may be vulnerable to SQL injection."