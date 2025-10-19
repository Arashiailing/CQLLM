/**
 * @name CSV Injection Vulnerability
 * @description Identifies potential CSV injection flaws where unsanitized user input
 *              is written to CSV files, enabling execution of malicious formulas
 *              or commands when opened in spreadsheet applications
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

// Import core Python analysis libraries for code parsing and evaluation
import python

// Import path graph representation for CSV injection data flow tracking
import CsvInjectionFlow::PathGraph

// Import data flow framework to trace information movement through the program
import semmle.python.dataflow.new.DataFlow

// Import experimental CSV injection detection utilities and configurations
import experimental.semmle.python.security.injection.CsvInjection

// Define source and sink components for the data flow analysis
from 
  CsvInjectionFlow::PathNode maliciousInputSource,
  CsvInjectionFlow::PathNode csvOutputSink
where 
  CsvInjectionFlow::flowPath(maliciousInputSource, csvOutputSink)

// Generate vulnerability report with source and sink details
select 
  csvOutputSink.getNode(), 
  maliciousInputSource, 
  csvOutputSink, 
  "CSV injection may include code from $@.", 
  maliciousInputSource.getNode(),
  "this user input"