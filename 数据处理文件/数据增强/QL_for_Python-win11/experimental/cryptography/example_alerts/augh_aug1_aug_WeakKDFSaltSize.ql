/**
 * @name Insufficient KDF Salt Size
 * @description Identifies Key Derivation Function (KDF) operations using salt sizes below the recommended 128 bits (16 bytes).
 *
 * This rule flags KDF operations where the salt size is either:
 * - Statically determined to be less than 128 bits (16 bytes)
 * - Cannot be statically determined during analysis
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Query to identify KDF operations with insufficient salt size
from KeyDerivationOperation keyDerivationOp, DataFlow::Node saltSizeSource, API::CallNode urandomCall, string alertMessage
where
  // Ensure the KDF operation requires a salt
  keyDerivationOp.requiresSalt() and
  
  // Verify salt configuration originates from os.urandom
  urandomCall = keyDerivationOp.getSaltConfigSrc() and
  urandomCall = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Trace the ultimate source of the salt size parameter
  saltSizeSource = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Check for problematic salt size configurations
  (
    // Case 1: Salt size cannot be statically verified
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt config is not a statically verifiable size. "
    or
    // Case 2: Salt size is below the minimum requirement
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt config is insufficiently large. "
  )
select keyDerivationOp,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", urandomCall,
  urandomCall.toString(), saltSizeSource, saltSizeSource.toString()