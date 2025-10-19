/**
* @name CWE-264: SQL Injection Query
*
@description Using user-controlled input in SQL queries can lead to SQL injection vulnerabilities.
* @kind path-problem
* @problem.severity error
* @security-severity 8.8
* @precision high
*
@id py/sql-injection
*/
import python
import semmle.python.security.dataflow.SqlInjectionQuery
import SqlInjectionFlow::PathGraph
from SqlInjectionFlow::PathNode source, SqlInjectionFlow::PathNode sink
    where SqlInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This SQL query depends on a $@.", source.getNode(), "user-provided value"