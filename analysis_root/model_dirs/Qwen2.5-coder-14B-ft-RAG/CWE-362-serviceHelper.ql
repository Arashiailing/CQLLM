/**
 * @name CWE-362: Concurrent Execution using Shared Resource with Improper Synchronization ('Race Condition')
 * @description The product contains a concurrent code sequence that requires temporary, exclusive access to a shared resource, but a timing window exists in which the shared resource can be modified by another code sequence operating concurrently.
 * @kind problem
 * @tags reliability
 *       concurrency
 *       external/cwe/cwe-362
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/serviceHelper
 */

import python
import semmle.python.Concepts

from Function f
where
  not f.getScope().(Module).getBasicName() = "unittest"
  and
  (
    f.isService()
    or
    f.isApiFunction()
  )
select f, "This service helper method '" + f.getName() + "' could have side effects."