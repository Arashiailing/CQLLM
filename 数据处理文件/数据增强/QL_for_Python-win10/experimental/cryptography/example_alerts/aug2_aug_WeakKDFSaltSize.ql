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

// Define the main query to detect insufficient KDF salt size
from KeyDerivationOperation kdfOperation, DataFlow::Node saltSizeParam, API::CallNode urandomInvocation, string warningMessage
where
  // Ensure the operation requires a salt
  kdfOperation.requiresSalt() and
  
  // Verify that the urandom call is the salt configuration source
  urandomInvocation = kdfOperation.getSaltConfigSrc() and
  
  // Confirm the call is to os.urandom
  urandomInvocation = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Trace the salt size parameter to its ultimate source
  saltSizeParam = Utils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size")) and
  
  // Check for two problematic scenarios
  (
    // Scenario 1: Salt size is not statically verifiable
    not exists(saltSizeParam.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Salt config is not a statically verifiable size. "
    or
    // Scenario 2: Salt size is less than the minimum required (16 bytes)
    saltSizeParam.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMessage = "Salt config is insufficiently large. "
  )
  
// Select the KDF operation and format the output message
select kdfOperation,
  warningMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomInvocation,
  urandomInvocation.toString(), 
  saltSizeParam, 
  saltSizeParam.toString()