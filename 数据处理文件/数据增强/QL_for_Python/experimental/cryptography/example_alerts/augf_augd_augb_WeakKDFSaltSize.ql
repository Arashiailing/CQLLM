/**
 * @name Insufficient KDF Salt Length
 * @description Detects key derivation functions using salt values shorter than the recommended 128 bits (16 bytes).
 * 
 * Identifies two problematic salt configurations:
 * 1. Salt size explicitly set to a constant value less than 16 bytes
 * 2. Salt size dynamically determined without static verification capability
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation kdfOp, 
     DataFlow::Node saltSizeNode, 
     API::CallNode urandomCall, 
     string alertMessage
where
  // Validate that the key derivation operation requires salt configuration
  kdfOp.requiresSalt() and
  
  // Identify os.urandom calls utilized for salt generation
  API::moduleImport("os").getMember("urandom").getACall() = urandomCall and
  
  // Confirm this call is responsible for configuring the salt
  urandomCall = kdfOp.getSaltConfigSrc() and
  
  // Trace the size parameter to its ultimate source
  saltSizeNode = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Evaluate for problematic salt size configurations
  (
    // Case 1: Non-constant salt size (cannot be statically verified)
    not exists(saltSizeNode.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt size is not statically verifiable. "
    or
    // Case 2: Constant salt size below the security threshold
    saltSizeNode.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt size is below the recommended minimum. "
  )

select kdfOp,
  alertMessage + "Salt size must be at least 16 bytes. os.urandom Configuration: $@, Size Parameter: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeNode, saltSizeNode.toString()