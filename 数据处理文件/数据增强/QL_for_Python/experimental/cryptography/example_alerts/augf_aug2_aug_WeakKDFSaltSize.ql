/**
 * @name Inadequate KDF Salt Length
 * @description Key Derivation Function (KDF) salts should be at least 128 bits (16 bytes) long.
 *
 * This rule detects two security issues:
 * 1. Salt size configuration is below the required 128 bits
 * 2. Salt size cannot be determined statically during analysis
 * 
 * The rule specifically examines salt configurations that use os.urandom() calls.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Main query to identify KDF operations with insufficient salt size
from KeyDerivationOperation keyDerivationFunc, DataFlow::Node saltSizeArg, API::CallNode urandomCall, string alertMsg
where
  // Check that the KDF operation requires a salt
  keyDerivationFunc.requiresSalt() and
  
  // Verify that the salt configuration comes from a urandom call
  urandomCall = keyDerivationFunc.getSaltConfigSrc() and
  
  // Ensure the call is to os.urandom
  urandomCall = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Trace the salt size parameter to its source
  saltSizeArg = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Identify problematic salt size configurations
  (
    // Case 1: Salt size cannot be statically verified
    not exists(saltSizeArg.asExpr().(IntegerLiteral).getValue()) and
    alertMsg = "Salt size is not statically verifiable. "
    or
    // Case 2: Salt size is below the minimum requirement (16 bytes)
    saltSizeArg.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMsg = "Salt size is too small. "
  )
  
// Output the KDF operation with a formatted warning message
select keyDerivationFunc,
  alertMsg + "Salt size must be at least 16 bytes. os.urandom Config: $@, Size Config: $@", 
  urandomCall,
  urandomCall.toString(), 
  saltSizeArg, 
  saltSizeArg.toString()