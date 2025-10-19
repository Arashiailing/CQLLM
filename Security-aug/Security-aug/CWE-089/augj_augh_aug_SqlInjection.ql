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

// Import the Python analysis library for code parsing and processing
import python

// Import the specialized SQL injection data flow tracking module
import semmle.python.security.dataflow.SqlInjectionQuery

// Import the path graph module for visualizing data flow trajectories
import SqlInjectionFlow::PathGraph

// Identify data flow paths from user-controlled sources to SQL construction points
from 
  SqlInjectionFlow::PathNode maliciousInputSource, 
  SqlInjectionFlow::PathNode sqlConstructionPoint
where 
  // Validate that tainted data flows from source to SQL construction point
  SqlInjectionFlow::flowPath(maliciousInputSource, sqlConstructionPoint)
select 
  sqlConstructionPoint.getNode(),     // Target SQL construction point
  maliciousInputSource,               // Origin of tainted data
  sqlConstructionPoint,               // Termination point of flow
  "This SQL query depends on a $@.",   // Vulnerability description template
  maliciousInputSource.getNode(),     // Source node for placeholder substitution
  "user-provided value"               // Label for tainted data origin