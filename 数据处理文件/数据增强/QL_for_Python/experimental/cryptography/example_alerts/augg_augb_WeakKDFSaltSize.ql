/**
 * @name Insufficient KDF Salt Length
 * @description Identifies key derivation functions using salt values shorter than 128 bits (16 bytes).
 * 
 * This query detects two security issues:
 * 1. Salt size configured with a constant value less than 16 bytes
 * 2. Salt size that cannot be statically verified (non-constant configuration)
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation kdfOperation, 
     DataFlow::Node saltLengthOrigin, 
     API::CallNode randomCall, 
     string alertText
where
  // Validate that the key derivation function requires salt configuration
  kdfOperation.requiresSalt() and
  
  // Identify os.urandom function calls used for generating salt values
  API::moduleImport("os").getMember("urandom").getACall() = randomCall and
  
  // Establish connection between the random call and KDF salt configuration
  randomCall = kdfOperation.getSaltConfigSrc() and
  
  // Trace back to determine the source of the size parameter
  saltLengthOrigin = CryptoUtils::getUltimateSrcFromApiNode(randomCall.getParameter(0, "size")) and
  
  // Analyze salt size configuration against security requirements
  (
    // Case 1: Salt size is not a constant value (cannot be statically verified)
    not exists(saltLengthOrigin.asExpr().(IntegerLiteral).getValue()) and
    alertText = "Salt config is not a statically verifiable size. "
    or
    // Case 2: Salt size is a constant but below minimum security threshold
    saltLengthOrigin.asExpr().(IntegerLiteral).getValue() < 16 and
    alertText = "Salt config is insufficiently large. "
  )

select kdfOperation,
  alertText + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  randomCall, randomCall.toString(), 
  saltLengthOrigin, saltLengthOrigin.toString()