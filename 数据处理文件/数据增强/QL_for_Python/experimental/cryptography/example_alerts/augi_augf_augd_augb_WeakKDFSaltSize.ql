/**
 * @name Inadequate KDF Salt Length
 * @description Identifies key derivation functions that utilize salt values with insufficient length (less than the recommended 128 bits or 16 bytes).
 * 
 * Detects two types of insecure salt configurations:
 * 1. Salt size explicitly configured as a constant value below the 16-byte threshold
 * 2. Salt size determined dynamically, preventing static analysis verification
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation keyDerivFunc, 
     DataFlow::Node saltLengthSrc, 
     API::CallNode randomGenCall, 
     string warningMsg
where
  // Ensure the key derivation function requires salt configuration
  keyDerivFunc.requiresSalt() and
  
  // Locate os.urandom invocations used for generating salt values
  API::moduleImport("os").getMember("urandom").getACall() = randomGenCall and
  
  // Verify this call is indeed configuring the salt parameter
  randomGenCall = keyDerivFunc.getSaltConfigSrc() and
  
  // Trace back to the origin of the size parameter
  saltLengthSrc = CryptoUtils::getUltimateSrcFromApiNode(randomGenCall.getParameter(0, "size")) and
  
  // Check for problematic salt size configurations
  (
    // Scenario 1: Variable salt size (prevents static verification)
    not exists(saltLengthSrc.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Salt size is not statically verifiable. "
    or
    // Scenario 2: Constant salt size below security requirements
    saltLengthSrc.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMsg = "Salt size is below the recommended minimum. "
  )

select keyDerivFunc,
  warningMsg + "Salt size must be at least 16 bytes. os.urandom Configuration: $@, Size Parameter: $@", 
  randomGenCall, randomGenCall.toString(), 
  saltLengthSrc, saltLengthSrc.toString()