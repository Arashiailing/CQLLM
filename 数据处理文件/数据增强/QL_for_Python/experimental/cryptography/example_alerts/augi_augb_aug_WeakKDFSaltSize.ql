/**
 * @name Inadequate KDF Salt Length
 * @description Cryptographic key derivation requires salt values of at least 128 bits (16 bytes) to ensure security.
 *
 * This query detects vulnerabilities where the salt size in key derivation functions is below the
 * recommended 128 bits minimum, or when the salt size cannot be determined through static analysis.
 * Using insufficient salt sizes weakens cryptographic protection by increasing vulnerability to
 * brute-force attacks against derived keys.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

// Query definition: Identifies key derivation functions with inadequate salt size
from KeyDerivationOperation keyDerivationFunc, DataFlow::Node saltSizeArg, API::CallNode urandomCall, string alertMessage
where
  // Essential condition: The key derivation function requires a salt
  keyDerivationFunc.requiresSalt() and
  
  // Salt source verification: Confirms os.urandom is used as the salt source
  urandomCall = keyDerivationFunc.getSaltConfigSrc() and
  urandomCall = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Parameter tracking: Identifies the ultimate source of the salt size parameter
  saltSizeArg = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Security assessment: Evaluates salt size for potential vulnerabilities
  (
    // Vulnerability case 1: Salt size is not statically determinable
    not exists(saltSizeArg.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt configuration uses a non-static size value. "
    or
    // Vulnerability case 2: Salt size is below the security minimum
    saltSizeArg.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt configuration size is below security threshold. "
  )
select keyDerivationFunc,  // Target: The vulnerable key derivation operation
  alertMessage + "Minimum salt size requirement is 16 bytes. os.urandom Configuration: $@, Size Parameter: $@",  // Alert construction
  urandomCall, urandomCall.toString(),  // Reference: urandom invocation details
  saltSizeArg, saltSizeArg.toString()  // Reference: Salt size parameter details