/**
 * @name CWE-284: Improper Access Control
 * @description nan
 * @kind problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision medium
 * @id py/RegistrationTool
 * @tags test
 */

import python
import semmle.python.ApiGraphs
import semmle.python.ClueProvider
import CleartextStorageQuery

from Clue c
where CleartextStorageQuery::cleartext_storage_query(c)
select c.getNode(), "Data is written to a file without encryption."