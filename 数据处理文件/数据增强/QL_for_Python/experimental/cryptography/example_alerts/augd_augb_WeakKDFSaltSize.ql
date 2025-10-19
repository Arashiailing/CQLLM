/**
 * @name Insufficient KDF Salt Length
 * @description Identifies key derivation functions that utilize salt values shorter than the recommended 128 bits (16 bytes).
 * 
 * This query detects two problematic salt configurations:
 * 1. Salt size is explicitly set to a constant value less than 16 bytes
 * 2. Salt size is dynamically determined and cannot be statically verified
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation kdfOperation, 
     DataFlow::Node saltSizeParam, 
     API::CallNode randomGeneratorCall, 
     string warningMsg
where
  // Ensure the key derivation operation requires salt configuration
  kdfOperation.requiresSalt() and
  
  // Locate os.urandom calls being used for salt generation
  API::moduleImport("os").getMember("urandom").getACall() = randomGeneratorCall and
  
  // Verify this call is responsible for configuring the salt
  randomGeneratorCall = kdfOperation.getSaltConfigSrc() and
  
  // Trace the size parameter back to its ultimate source
  saltSizeParam = CryptoUtils::getUltimateSrcFromApiNode(randomGeneratorCall.getParameter(0, "size")) and
  
  // Check for problematic salt size configurations
  (
    // Scenario 1: Non-constant salt size (cannot be statically verified)
    not exists(saltSizeParam.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Salt configuration uses a non-statically verifiable size. "
    or
    // Scenario 2: Constant salt size below the minimum threshold
    saltSizeParam.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMsg = "Salt configuration is below the recommended minimum size. "
  )

select kdfOperation,
  warningMsg + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  randomGeneratorCall, randomGeneratorCall.toString(), 
  saltSizeParam, saltSizeParam.toString()