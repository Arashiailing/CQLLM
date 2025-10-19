/**
 * @name Csv Injection
 * @description Identifies potential CSV injection vulnerabilities where untrusted data
 *              is written to CSV files without sanitization, enabling malicious formulas
 *              or commands to execute when opened in spreadsheet applications
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

// Import core Python analysis modules for code parsing and evaluation
import python

// Import path graph representation for tracking CSV injection data flows
import CsvInjectionFlow::PathGraph

// Import data flow analysis framework to trace information propagation
import semmle.python.dataflow.new.DataFlow

// Import experimental CSV injection detection utilities and configurations
import experimental.semmle.python.security.injection.CsvInjection

// Define the vulnerable data flow pattern from untrusted sources to CSV sinks
from CsvInjectionFlow::PathNode userInputSource, CsvInjectionFlow::PathNode csvOutputSink
where CsvInjectionFlow::flowPath(userInputSource, csvOutputSink)

// Generate vulnerability report with source and sink details
select 
  csvOutputSink.getNode(), 
  userInputSource, 
  csvOutputSink, 
  "CSV injection may execute code from $@.", 
  userInputSource.getNode(),
  "this untrusted input"