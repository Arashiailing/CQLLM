/**
 * @name CWE-684: Incorrect Provision of Specified Functionality
 * @description A program creates a new BrowserTab object without providing any functionality.
 * @kind problem
 * @problem.severity error
 * @security-severity 8.1
 * @precision high
 * @id py/browsertab
 * @tags reliability
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

from ApiGraph::CallNode tabCreation
where
  // Check if the BrowserTab class is instantiated
  tabCreation = ApiGraph::moduleImport("browser").getMember("BrowserTab").getACall()
  // Verify that no parameters are provided during instantiation
  and not exists(tabCreation.getArg(_))
select tabCreation,
  "Instantiation of 'BrowserTab' without specifying required capabilities."