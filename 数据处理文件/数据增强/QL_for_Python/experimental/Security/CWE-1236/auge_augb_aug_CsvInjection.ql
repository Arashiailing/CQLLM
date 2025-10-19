/**
 * @name Csv Injection
 * @description Detects potential CSV injection vulnerabilities where untrusted data
 *              is written to CSV files without proper sanitization. This could lead
 *              to execution of malicious formulas or commands when the CSV is opened
 *              in spreadsheet applications.
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

// Core Python analysis modules for AST parsing and semantic evaluation
import python

// Path graph representation for tracking CSV injection data flow paths
import CsvInjectionFlow::PathGraph

// Data flow framework for tracking information propagation through the code
import semmle.python.dataflow.new.DataFlow

// Experimental utilities and configurations for CSV injection detection
import experimental.semmle.python.security.injection.CsvInjection

// Define vulnerable data flow pattern from untrusted sources to CSV sinks
from CsvInjectionFlow::PathNode untrustedSource, CsvInjectionFlow::PathNode csvSink
where 
  // Verify existence of data flow path from source to sink
  CsvInjectionFlow::flowPath(untrustedSource, csvSink)

// Generate vulnerability report with source and sink details
select 
  csvSink.getNode(), 
  untrustedSource, 
  csvSink, 
  "CSV injection may execute code from $@.", 
  untrustedSource.getNode(),
  "this untrusted input"