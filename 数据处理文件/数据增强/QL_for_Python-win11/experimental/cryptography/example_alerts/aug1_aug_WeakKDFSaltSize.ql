/**
 * @name Insufficient KDF Salt Size
 * @description Detects Key Derivation Function (KDF) operations with salt sizes below 128 bits (16 bytes).
 *
 * This rule identifies KDF operations where the salt size is either statically determined to be
 * less than the required 128 bits, or cannot be statically determined during analysis.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Query to identify KDF operations with insufficient salt size
from KeyDerivationOperation kdfOperation, DataFlow::Node saltSizeParam, API::CallNode urandomInvocation, string warningMsg
where
  // Filter for KDF operations that require a salt
  kdfOperation.requiresSalt() and
  
  // Verify the salt configuration comes from os.urandom
  urandomInvocation = kdfOperation.getSaltConfigSrc() and
  urandomInvocation = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Extract the ultimate source of the salt size parameter
  saltSizeParam = Utils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size")) and
  
  // Check for two problematic scenarios
  (
    // Scenario 1: Salt size is not statically verifiable
    not exists(saltSizeParam.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Salt config is not a statically verifiable size. "
    or
    // Scenario 2: Salt size is insufficiently large
    saltSizeParam.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMsg = "Salt config is insufficiently large. "
  )
select kdfOperation,
  warningMsg + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", urandomInvocation,
  urandomInvocation.toString(), saltSizeParam, saltSizeParam.toString()