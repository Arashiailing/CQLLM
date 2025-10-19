/**
 * @name Insufficient KDF Salt Size
 * @description Key Derivation Function (KDF) salts must be at least 128 bits (16 bytes) in length.
 *
 * Detects two security issues:
 * 1. Salt size configuration below 128-bit minimum requirement
 * 2. Salt size that cannot be statically determined during analysis
 * 
 * Specifically targets salt configurations using os.urandom() calls.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

// Identify KDF operations with problematic salt configurations
from KeyDerivationOperation keyDerivationOp, 
     DataFlow::Node saltSizeNode, 
     API::CallNode urandomCall, 
     string alertMessage
where
  // Verify KDF operation requires salt parameter
  keyDerivationOp.requiresSalt() and
  
  // Confirm salt configuration originates from os.urandom
  urandomCall = keyDerivationOp.getSaltConfigSrc() and
  urandomCall = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Trace salt size parameter to its ultimate source
  saltSizeNode = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Detect two distinct vulnerability patterns
  (
    // Pattern 1: Non-static salt size (cannot verify at analysis time)
    not exists(saltSizeNode.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt config is not a statically verifiable size. "
    or
    // Pattern 2: Salt size below 16-byte minimum
    saltSizeNode.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt config is insufficiently large. "
  )

// Report findings with contextual information
select keyDerivationOp,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomCall,
  urandomCall.toString(), 
  saltSizeNode, 
  saltSizeNode.toString()