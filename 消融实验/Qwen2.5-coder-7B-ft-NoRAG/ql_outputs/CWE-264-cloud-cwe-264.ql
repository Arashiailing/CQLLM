/**
 * @name CWE-264: Cleartext storage of sensitive data
 * @description Storing sensitive data in cleartext can lead to unauthorized access.
 * @kind problem
 * @problem.severity warning
 * @precision high
 * @security-severity 8.8
 * @id py/cloud-cwe-264
 */

import python
import external.cloudstorage.CleartextStorageQuery

predicate isSensitiveData(string data) {
  // Define criteria for identifying sensitive data (e.g., credit card numbers, passwords)
  data.matches("[0-9]{16}") or
  data.contains("password") or
  data.contains("secret")
}

from File file, Call call, string data
where
  file.hasText(data) and
  call.getFunc().pointsTo(CleartextStorageQuery::storeData) and
  call.getArgument(0).getValue() = data and
  isSensitiveData(data)
select call, "Storing sensitive data in cleartext is insecure."