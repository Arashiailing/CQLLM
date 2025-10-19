/**
 * @name Csv Injection
 * @description Detects potential CSV injection vulnerabilities where untrusted user input
 *              is written to CSV files without proper sanitization, allowing malicious
 *              formulas or commands to be executed when the CSV is opened in spreadsheet software
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

// Import necessary Python analysis libraries for code parsing and evaluation
import python

// Import the path graph representation for CSV injection data flow tracking
import CsvInjectionFlow::PathGraph

// Import data flow analysis framework to trace information movement through the program
import semmle.python.dataflow.new.DataFlow

// Import experimental CSV injection detection utilities and configurations
import experimental.semmle.python.security.injection.CsvInjection

// Define the entry and exit points of the data flow we're interested in
from CsvInjectionFlow::PathNode untrustedSource, CsvInjectionFlow::PathNode csvSink
where CsvInjectionFlow::flowPath(untrustedSource, csvSink)

// Report the vulnerability with source and sink information
select 
  csvSink.getNode(), 
  untrustedSource, 
  csvSink, 
  "Csv injection might include code from $@.", 
  untrustedSource.getNode(),
  "this user input"