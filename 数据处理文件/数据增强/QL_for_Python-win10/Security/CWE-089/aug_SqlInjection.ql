/**
 * @name SQL query built from user-controlled sources
 * @description Constructing SQL queries using user-controlled input enables attackers
 *              to inject malicious SQL code, creating SQL injection vulnerabilities.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// Import Python analysis library for code parsing and processing
import python

// Import specialized SQL injection data flow tracking module
import semmle.python.security.dataflow.SqlInjectionQuery

// Import path graph module for visualizing data flow trajectories
import SqlInjectionFlow::PathGraph

// Identify data flow paths from malicious input sources to vulnerable SQL sinks
from SqlInjectionFlow::PathNode maliciousInput, SqlInjectionFlow::PathNode vulnerableSql
where SqlInjectionFlow::flowPath(maliciousInput, vulnerableSql)  // Validate data flow existence
select 
  vulnerableSql.getNode(),  // Target SQL construction point
  maliciousInput,          // Origin of tainted data
  vulnerableSql,            // Termination point of flow
  "This SQL query depends on a $@.",  // Vulnerability description template
  maliciousInput.getNode(), // Source node for placeholder substitution
  "user-provided value"     // Label for tainted data origin