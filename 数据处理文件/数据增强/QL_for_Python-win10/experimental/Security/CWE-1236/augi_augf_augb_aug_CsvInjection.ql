/**
 * @name Csv Injection
 * @description Identifies potential CSV injection vulnerabilities where unvalidated data
 *              is written to CSV files without proper sanitization. This enables malicious
 *              formulas or commands to execute when the CSV is opened in spreadsheet applications.
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

// Define vulnerable data flow pattern from malicious input sources to CSV output sinks
from 
  CsvInjectionFlow::PathNode maliciousInputSource, 
  CsvInjectionFlow::PathNode csvOutputSink
where 
  // Establish data flow path from untrusted source to CSV sink
  CsvInjectionFlow::flowPath(maliciousInputSource, csvOutputSink)

// Generate vulnerability report with source and sink details
select 
  csvOutputSink.getNode(), 
  maliciousInputSource, 
  csvOutputSink, 
  "CSV injection may execute code from $@.", 
  maliciousInputSource.getNode(),
  "this untrusted input"