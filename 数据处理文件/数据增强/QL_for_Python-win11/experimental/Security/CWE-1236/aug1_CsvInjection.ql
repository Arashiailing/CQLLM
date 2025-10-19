/**
 * @name Csv Injection
 * @description Detects potential CSV injection vulnerabilities where user-controlled data
 *              could execute malicious formulas when exported to CSV files
 * @kind path-problem
 * @problem.severity error
 * @id py/csv-injection
 * @tags security
 *       experimental
 *       external/cwe/cwe-1236
 */

import python
import CsvInjectionFlow::PathGraph
import semmle.python.dataflow.new.DataFlow
import experimental.semmle.python.security.injection.CsvInjection

from CsvInjectionFlow::PathNode origin, CsvInjectionFlow::PathNode destination
where CsvInjectionFlow::flowPath(origin, destination)
select destination.getNode(), 
       origin, 
       destination, 
       "Csv injection might include code from $@.", 
       origin.getNode(), 
       "this user input"