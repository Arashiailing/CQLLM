/**
 * @name CSV Injection Vulnerability
 * @description Identifies potential CSV injection flaws where user-supplied data is written to a CSV file,
 *              which could lead to information disclosure or other malicious actions when opened in spreadsheet software.
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

// Import the Python library for parsing and analyzing Python code
import python

// Import the CSV injection flow path graph for tracking data flow paths
import CsvInjectionFlow::PathGraph

// Import data flow analysis module for tracking data movement in programs
import semmle.python.dataflow.new.DataFlow

// Import experimental CSV injection detection capabilities
import experimental.semmle.python.security.injection.CsvInjection

// Define untrusted data source and CSV output sink nodes
from CsvInjectionFlow::PathNode untrustedSource, CsvInjectionFlow::PathNode csvSink

// Check if data flows from untrusted source to CSV sink
where CsvInjectionFlow::flowPath(untrustedSource, csvSink)

// Select and report potential CSV injection vulnerabilities
select csvSink.getNode(), untrustedSource, csvSink, "CSV injection might include code from $@.", untrustedSource.getNode(),
  "this user input"