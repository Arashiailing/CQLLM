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

// Import experimental CSV injection detection utilities and configurations
import experimental.semmle.python.security.injection.CsvInjection

// Import the path graph representation for CSV injection data flow tracking
import CsvInjectionFlow::PathGraph

// Import data flow analysis framework to trace information movement through the program
import semmle.python.dataflow.new.DataFlow

// Import necessary Python analysis libraries for code parsing and evaluation
import python

// Define entry and exit points of the data flow path being analyzed
from CsvInjectionFlow::PathNode userInputSource, CsvInjectionFlow::PathNode csvOutputSink
where CsvInjectionFlow::flowPath(userInputSource, csvOutputSink)

// Generate vulnerability report with source and sink details
select
  csvOutputSink.getNode(),
  userInputSource,
  csvOutputSink,
  "Csv injection might include code from $@.",
  userInputSource.getNode(),
  "this user input"