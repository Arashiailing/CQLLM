/**
 * @name Insufficient KDF Salt Length
 * @description Detects key derivation functions that use salt values shorter than the security recommendation of 128 bits (16 bytes).
 * 
 * This analysis identifies two types of vulnerable salt configurations:
 * 1. Salt size explicitly configured with a constant value less than 16 bytes
 * 2. Salt size determined dynamically at runtime, preventing static security verification
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation keyDerivationFunc, 
     DataFlow::Node saltLengthNode, 
     API::CallNode urandomInvocation, 
     string alertMessage
where
  // Verify that the key derivation function requires salt configuration
  keyDerivationFunc.requiresSalt() and
  
  // Identify os.urandom calls utilized for salt generation
  API::moduleImport("os").getMember("urandom").getACall() = urandomInvocation and
  
  // Confirm the urandom call is directly responsible for salt configuration
  urandomInvocation = keyDerivationFunc.getSaltConfigSrc() and
  
  // Trace the size parameter to its ultimate source
  saltLengthNode = CryptoUtils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size")) and
  
  // Evaluate salt size configuration for security issues
  (
    // Case 1: Dynamic salt size (cannot be statically verified for security)
    not exists(saltLengthNode.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt size is dynamically determined and cannot be statically verified. "
    or
    // Case 2: Static salt size below security threshold
    saltLengthNode.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt size is below the recommended security threshold. "
  )

select keyDerivationFunc,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomInvocation, urandomInvocation.toString(), 
  saltLengthNode, saltLengthNode.toString()