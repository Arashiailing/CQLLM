/**
 * @name Csv Injection
 * @description Identifies potential CSV injection vulnerabilities that occur when
 *              untrusted user input is embedded into CSV files without adequate
 *              sanitization. This can result in the execution of arbitrary formulas
 *              or commands when the CSV file is opened in spreadsheet software.
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
from CsvInjectionFlow::PathNode maliciousInputSource, CsvInjectionFlow::PathNode vulnerableCsvSink
where 
  // Verify existence of data flow path from source to sink
  CsvInjectionFlow::flowPath(maliciousInputSource, vulnerableCsvSink)

// Generate vulnerability report with source and sink details
select 
  vulnerableCsvSink.getNode(), 
  maliciousInputSource, 
  vulnerableCsvSink, 
  "CSV injection may execute code from $@.", 
  maliciousInputSource.getNode(),
  "this malicious input source"