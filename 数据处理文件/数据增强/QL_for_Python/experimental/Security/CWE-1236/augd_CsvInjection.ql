/**
 * @name Csv Injection
 * @description Detects potential CSV injection vulnerabilities where user-controlled data
 *              in CSV files could be interpreted as malicious commands by spreadsheet software,
 *              leading to information disclosure or code execution
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

// Core Python analysis libraries
import python

// Path graph for tracking CSV injection data flows
import CsvInjectionFlow::PathGraph

// Data flow analysis framework
import semmle.python.dataflow.new.DataFlow

// Experimental CSV injection detection utilities
import experimental.semmle.python.security.injection.CsvInjection

// Define data flow source and sink nodes for analysis
from CsvInjectionFlow::PathNode source, CsvInjectionFlow::PathNode sink

// Identify vulnerable paths where tainted data reaches CSV output
where CsvInjectionFlow::flowPath(source, sink)

// Report findings with vulnerability details
select sink.getNode(), source, sink, "Csv injection might include code from $@.", source.getNode(),
  "this user input"