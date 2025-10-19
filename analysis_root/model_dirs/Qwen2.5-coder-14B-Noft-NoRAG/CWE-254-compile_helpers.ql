import python

/**
 * @name CWE-254: Unprotected Storage of Sensitive Information
 * @description Detects instances where sensitive information is stored in an insecure manner.
 * @id py/compile_helpers
 */

class SensitiveDataStorage extends DataFlow::Node {
  SensitiveDataStorage() {
    this instanceof CallExpr and
    this.getCallee().getName() = "compile_helpers" and
    this.getArgument(0).toString() =~ /.*password.*|.*secret.*|.*key.*/
  }
}

from SensitiveDataStorage dataStorage
select dataStorage, "Sensitive data is being stored in an insecure manner."