/**
 * @name Csv Injection
 * @description Detects potential CSV injection vulnerabilities arising from embedding
 *              unvalidated user input into CSV files. Such vulnerabilities can lead
 *              to execution of arbitrary formulas or commands when the CSV is opened
 *              in spreadsheet applications like Excel.
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

// Import essential Python analysis modules for AST parsing and semantic evaluation
import python

// Import path graph module for visualizing CSV injection data flow trajectories
import CsvInjectionFlow::PathGraph

// Import data flow framework to trace information propagation through the codebase
import semmle.python.dataflow.new.DataFlow

// Import specialized utilities for CSV injection vulnerability detection
import experimental.semmle.python.security.injection.CsvInjection

// Identify data flow paths that could lead to CSV injection
from CsvInjectionFlow::PathNode untrustedDataSource, CsvInjectionFlow::PathNode csvInjectionSink
where 
  // Confirm that untrusted data flows to a CSV output without proper sanitization
  CsvInjectionFlow::flowPath(untrustedDataSource, csvInjectionSink)

// Report the vulnerability with details about the source and sink
select 
  csvInjectionSink.getNode(), 
  untrustedDataSource, 
  csvInjectionSink, 
  "CSV injection may execute code from $@.", 
  untrustedDataSource.getNode(),
  "this untrusted data source"