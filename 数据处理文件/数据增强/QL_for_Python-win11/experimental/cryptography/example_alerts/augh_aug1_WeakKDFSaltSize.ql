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

from KeyDerivationOperation keyDerivationFunc, DataFlow::Node saltSizeSource, API::CallNode randomGeneratorCall, string alertMessage
where
  // Focus on KDF operations that require salt configuration
  keyDerivationFunc.requiresSalt() and
  
  // Identify os.urandom calls used for salt generation
  API::moduleImport("os").getMember("urandom").getACall() = randomGeneratorCall and
  randomGeneratorCall = keyDerivationFunc.getSaltConfigSrc() and
  
  // Trace the source of the size parameter passed to os.urandom
  saltSizeSource = Utils::getUltimateSrcFromApiNode(randomGeneratorCall.getParameter(0, "size")) and
  
  // Determine if salt size is insufficient or cannot be statically verified
  (
    // Case 1: Salt size is not statically verifiable
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt configuration is not a statically verifiable size. "
    or
    // Case 2: Salt size is less than the required minimum (16 bytes)
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt configuration is insufficiently large. "
  )
select keyDerivationFunc,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  randomGeneratorCall, randomGeneratorCall.toString(), 
  saltSizeSource, saltSizeSource.toString()