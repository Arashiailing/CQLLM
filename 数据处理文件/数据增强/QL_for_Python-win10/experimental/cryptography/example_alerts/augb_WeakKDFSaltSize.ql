/**
 * @name Insufficient KDF Salt Length
 * @description Detects key derivation functions using salt values shorter than 128 bits (16 bytes).
 * 
 * Identifies two scenarios:
 * 1. Salt size is configured with a constant value less than 16 bytes
 * 2. Salt size cannot be statically verified (non-constant configuration)
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation keyDerivationOp, 
     DataFlow::Node saltSizeSource, 
     API::CallNode urandomCall, 
     string alertMessage
where
  // Verify operation requires salt configuration
  keyDerivationOp.requiresSalt() and
  
  // Identify os.urandom calls used for salt generation
  API::moduleImport("os").getMember("urandom").getACall() = urandomCall and
  
  // Confirm this call configures salt for the key derivation
  urandomCall = keyDerivationOp.getSaltConfigSrc() and
  
  // Trace back to the ultimate source of the size parameter
  saltSizeSource = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Evaluate salt size configuration
  (
    // Case 1: Non-constant salt size (statically unverifiable)
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt config is not a statically verifiable size. "
    or
    // Case 2: Constant salt size below minimum threshold
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt config is insufficiently large. "
  )

select keyDerivationOp,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSource, saltSizeSource.toString()