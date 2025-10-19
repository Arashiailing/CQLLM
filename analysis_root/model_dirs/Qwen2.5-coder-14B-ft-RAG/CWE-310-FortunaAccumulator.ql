/**
 * @name CWE CATEGORY: Cryptographic Issues
 * @description nan
 * @kind problem
 * @problem.severity warning
 * @id py/FortunaAccumulator
 * @tags security
 *       external/cwe/cwe-310
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests

predicate is_sensitive_data(string data) {
  exists(string prefix |
    (
      prefix = "password" or
      prefix = "passwd" or
      prefix = "pass" or
      prefix = "pwd" or
      prefix = "secret"
    )
    and
    data.regexpMatch("(?i).*" + prefix + ".*")
  )
}

predicate is_hash_function(DataFlow::Node n, string func) {
  n = DataFlow::moduleImport("hashlib").getMember(func).getReturn()
}

from DataFlow::Node n, string func, string sensitive_data
where
  is_sensitive_data(sensitive_data) and
  is_hash_function(n, func) and
  not exists(int i | i < 5 | i = func.count("_"))
select n,
  "The deprecated MD5 hashing function should not be used for security purposes."