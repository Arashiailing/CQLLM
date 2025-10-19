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

// Define data flow source and sink endpoints
from 
  SqlInjectionFlow::PathNode taintOrigin,          // Origin of untrusted data
  SqlInjectionFlow::PathNode vulnerableSqlPoint    // Vulnerable SQL construction point

// Establish data flow connection between endpoints
where 
  SqlInjectionFlow::flowPath(taintOrigin, vulnerableSqlPoint)

// Generate vulnerability report with flow visualization
select 
  vulnerableSqlPoint.getNode(),          // Target SQL construction point
  taintOrigin,                           // Origin of tainted data
  vulnerableSqlPoint,                    // Termination point of flow
  "This SQL query depends on a $@.",     // Vulnerability description template
  taintOrigin.getNode(),                 // Source node for placeholder substitution
  "user-provided value"                  // Label for tainted data origin