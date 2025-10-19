/**
 * @name Insufficient KDF Salt Length
 * @description Identifies key derivation functions that use salt values shorter than 128 bits (16 bytes).
 * 
 * This query detects two security issues:
 * 1. Salt size is explicitly configured with a constant value less than 16 bytes
 * 2. Salt size cannot be statically determined (non-constant configuration)
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
     API::CallNode urandomInvocation, 
     string securityAlert
where
  // Ensure the key derivation operation requires salt configuration
  kdfOperation.requiresSalt() and
  
  // Identify os.urandom calls used for salt generation
  API::moduleImport("os").getMember("urandom").getACall() = urandomInvocation and
  
  // Verify this urandom call is configuring salt for the key derivation
  urandomInvocation = kdfOperation.getSaltConfigSrc() and
  
  // Trace back to the ultimate source of the size parameter
  saltSizeParam = CryptoUtils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size")) and
  
  // Evaluate salt size configuration for security issues
  (
    // Case 1: Salt size is not a constant (cannot be statically verified)
    not exists(saltSizeParam.asExpr().(IntegerLiteral).getValue()) and
    securityAlert = "Salt configuration size is not statically verifiable. "
    or
    // Case 2: Salt size is a constant but below the minimum threshold
    saltSizeParam.asExpr().(IntegerLiteral).getValue() < 16 and
    securityAlert = "Salt configuration size is insufficient. "
  )

select kdfOperation,
  securityAlert + "Minimum salt size must be 16 bytes. os.urandom Config: $@, Size Config: $@", 
  urandomInvocation, urandomInvocation.toString(), 
  saltSizeParam, saltSizeParam.toString()