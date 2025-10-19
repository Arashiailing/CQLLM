/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind problem
 * @problem.severity warning
 * @security-severity 5.0
 * @precision high
 * @id py/crypt
 * @tags security
 *       external/cwe/cwe-20
 */

import python
import semmle.python.Concepts

predicate cryptographically_weak_value(Value v) {
  v instanceof CryptographicallyWeakValue::CryptographicallyWeakValue
}

predicate encryption_operation(Call e) {
  e = any(CryptographicallyStrongEncryption::CryptographicallyStrongEncryption encryption).getACall()
}

encryption_operation(e) and
  not exists(Call call | call = e.getAStaticCall() | call.getFullyQualifiedName() = "cryptography.hazmat.primitives.kdf.pbkdf2.PBKDF2HMAC.derive")
)

// Check if the operation involves a hash algorithm
exists(String algName |
  algName = arg.getValue() and
  arg.getFunc().getFullyQualifiedName() = "hashlib.new"
)

// Ensure the operation uses a secure salt
salt_arg.getAParameterAccess().getParameter().getName() = "salt"

// Exclude known secure operations
not exists(
  salt_arg.getAParameterAccess().getParameter().getName() = "salt" and
  arg.getAParameterAccess().getParameter().getName() = "salt" and
  arg.getAParameterAccess().getParameter().getName() = "salt"
)

// Validate the key derivation function usage
exists(Call derive_call | derive_call = op.getAStaticCall() | derive_call.getFullyQualifiedName() = "cryptography.hazmat.primitives.kdf.pbkdf2.PBKDF2HMAC.derive")

// Verify correct usage of PBKDF2HMAC
pbkdf2_hmac_op.getAStaticCall().getFullyQualifiedName() = "cryptography.hazmat.primitives.kdf.pbkdf2.PBKDF2HMAC"

// Check if the HMAC is properly initialized
pbkdf2_hmac_op.getAStaticCall().getFullyQualifiedName() = "hmac.HMAC"