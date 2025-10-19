/**
 * @name Small KDF salt length.
 * @description Detects insufficient salt sizes in Key Derivation Functions (KDFs).
 * 
 * This query identifies KDF operations where:
 * 1. Salt size is not statically verifiable at compile time, or
 * 2. Salt size is statically known but less than 16 bytes (128 bits)
 * 
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation keyDerivationOp, DataFlow::Node saltSizeSource, API::CallNode urandomCall, string alertMessage
where
  // Ensure the operation requires salt configuration
  keyDerivationOp.requiresSalt() and
  
  // Identify os.urandom calls as salt sources
  urandomCall = API::moduleImport("os").getMember("urandom").getACall() and
  urandomCall = keyDerivationOp.getSaltConfigSrc() and
  
  // Trace the size parameter to its ultimate source
  saltSizeSource = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Check for insufficient or non-static salt sizes
  (
    // Case 1: Salt size cannot be statically determined
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt config is not a statically verifiable size. "
    or
    // Case 2: Salt size is statically known but too small
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt config is insufficiently large. "
  )

select keyDerivationOp, 
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSource, saltSizeSource.toString()