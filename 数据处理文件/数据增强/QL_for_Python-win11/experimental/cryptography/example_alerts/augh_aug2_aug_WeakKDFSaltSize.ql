/**
 * @name Insufficient KDF Salt Size
 * @description Key Derivation Function (KDF) salts must be at least 128 bits (16 bytes) in length.
 *
 * This rule identifies two types of issues:
 * 1. When a salt size configuration is less than the required 128 bits
 * 2. When the salt size cannot be statically determined at analysis time
 * 
 * The rule specifically checks for salt configurations using os.urandom() calls.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Identify KDF operations with problematic salt configurations
from KeyDerivationOperation kdfOp, DataFlow::Node saltSizeNode, API::CallNode urandomCall, string alertMessage
where
  // Verify the KDF operation requires salt configuration
  kdfOp.requiresSalt() and
  
  // Confirm salt source is an os.urandom() call
  urandomCall = kdfOp.getSaltConfigSrc() and
  urandomCall = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Trace the salt size parameter to its source
  saltSizeNode = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Detect two distinct salt configuration issues
  (
    // Case 1: Salt size is not statically determinable
    not exists(saltSizeNode.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt config is not a statically verifiable size. "
    or
    // Case 2: Salt size is below minimum requirement
    saltSizeNode.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt config is insufficiently large. "
  )

// Report findings with contextual information
select kdfOp,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomCall,
  urandomCall.toString(), 
  saltSizeNode, 
  saltSizeNode.toString()