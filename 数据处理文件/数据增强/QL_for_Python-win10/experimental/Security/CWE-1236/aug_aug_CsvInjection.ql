/**
 * @name Csv Injection
 * @description Identifies CSV injection vulnerabilities where untrusted data flows into 
 *              CSV exports without sanitization, potentially enabling malicious formula 
 *              execution when opened in spreadsheet applications
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

// Core Python analysis modules for code interpretation and evaluation
import python

// Path graph implementation for tracking CSV injection data flows
import CsvInjectionFlow::PathGraph

// Data flow analysis framework for tracking information propagation
import semmle.python.dataflow.new.DataFlow

// Experimental utilities for CSV injection vulnerability detection
import experimental.semmle.python.security.injection.CsvInjection

// Identify vulnerability paths between untrusted inputs and CSV outputs
from CsvInjectionFlow::PathNode maliciousInputSource, CsvInjectionFlow::PathNode csvOutputSink
where CsvInjectionFlow::flowPath(maliciousInputSource, csvOutputSink)

// Generate vulnerability report with source/sink context
select 
  csvOutputSink.getNode(), 
  maliciousInputSource, 
  csvOutputSink, 
  "CSV injection may execute code from $@.", 
  maliciousInputSource.getNode(),
  "this untrusted input"