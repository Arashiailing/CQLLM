/**
 * @name Cleartext Storage of Passwords
 * @description Detects passwords stored in plaintext in variables
 * @kind problem
 * @problem.severity error
 * @security-severity 8.3
 * @precision high
 * @id py/cleartext-storage
 * @tags security
 *       external/cwe/cwe-312
 */

import python
import semmle.python.dataflow.new.DataFlow
import CleartextStorageQuery

from DataFlow::Node variable, string passwordName
where
  variable = getSensitiveVariable(passwordName)
select variable,
  "$@ is a variable containing a " + passwordName + ".", variable, "Password"