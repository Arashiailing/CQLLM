/**
 * @name CWE-362: Concurrent Execution using Shared Resource with Improper Synchronization ('Race Condition')
 * @description The product contains a concurrent code sequence that requires temporary, exclusive access to a shared resource, but a timing window exists in which the shared resource can be modified by another code sequence operating concurrently.
 * @kind problem
 * @tags reliability
 *       correctness
 *       concurrency
 * @problem.severity warning
 * @sub-severity high
 * @precision medium
 * @id py/htpasswd
 */

import python
import semmle.python.Concepts

from HtpasswdFile f
select f, "Reference to htpasswd file " + f.getPath() + "."