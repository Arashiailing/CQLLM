/**
 * @name Insufficient KDF Salt Length
 * @description Identifies key derivation functions using salt values with inadequate length.
 * 
 * This rule detects scenarios where a KDF operation is configured with a salt size
 * below the recommended 128-bit (16-byte) threshold, or when the salt size
 * cannot be determined through static analysis.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOperation, DataFlow::Node saltSizeParam, API::CallNode urandomCall, string warningMessage
where
  // Identify KDF operations that require salt configuration
  kdfOperation.requiresSalt() and
  
  // Locate os.urandom calls used for salt generation
  API::moduleImport("os").getMember("urandom").getACall() = urandomCall and
  urandomCall = kdfOperation.getSaltConfigSrc() and
  
  // Trace the source of the size parameter passed to os.urandom
  saltSizeParam = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Check if salt size is insufficient or cannot be statically verified
  (
    // Case 1: Salt size is not statically verifiable
    not exists(saltSizeParam.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Salt configuration is not a statically verifiable size. "
    or
    // Case 2: Salt size is less than the required minimum (16 bytes)
    saltSizeParam.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMessage = "Salt configuration is insufficiently large. "
  )
select kdfOperation,
  warningMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeParam, saltSizeParam.toString()