/**
 * @name Insufficient KDF Salt Length
 * @description Detects key derivation functions that use salt values below the 128-bit (16-byte) security threshold.
 * 
 * This query identifies two critical security vulnerabilities:
 * 1. Salt size explicitly configured with a constant value less than 16 bytes
 * 2. Salt size determined at runtime (non-constant configuration) which cannot be statically verified
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation keyDerivationFunction, 
     DataFlow::Node saltSizeSource, 
     API::CallNode urandomCall, 
     string securityAlert
where
  // Ensure the key derivation function requires salt configuration
  keyDerivationFunction.requiresSalt() and
  
  // Locate os.urandom function calls used for salt generation
  API::moduleImport("os").getMember("urandom").getACall() = urandomCall and
  
  // Connect the urandom call to the KDF's salt configuration
  urandomCall = keyDerivationFunction.getSaltConfigSrc() and
  
  // Trace the size parameter back to its origin
  saltSizeSource = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Evaluate salt size against security requirements
  (
    // Scenario 1: Non-constant salt size (runtime determination)
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    securityAlert = "Salt size is not statically verifiable. "
    or
    // Scenario 2: Constant salt size below security minimum
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    securityAlert = "Salt size is insufficient. "
  )

select keyDerivationFunction,
  securityAlert + "Minimum required salt size is 16 bytes. os.urandom Configuration: $@, Size Parameter: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSource, saltSizeSource.toString()