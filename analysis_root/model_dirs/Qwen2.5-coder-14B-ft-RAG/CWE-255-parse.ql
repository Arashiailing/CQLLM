/**
 * @name CWE CATEGORY: Credentials Management Errors
 * @description nan
 * @kind problem
 * @id py/parse
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests

from DataFlow::Node hashInput, DataFlow::Node hashOutput
where
  exists(DataFlow::Config cfg |
    cfg = WeakSensitiveDataHashingQuery::config()
    and
    hashInput = cfg.getAConfiguredDataSource()
    and
    hashOutput = cfg.getAConfiguredDestination()
    and
    DataFlow::localFlow(hashInput, hashOutput)
  )
select hashOutput, "Sensitive data hashed by $@", hashInput, hashInput.toString()