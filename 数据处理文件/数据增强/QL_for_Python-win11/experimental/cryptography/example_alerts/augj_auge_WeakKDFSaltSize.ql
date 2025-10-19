/**
 * @name Insufficient KDF Salt Length
 * @description Identifies Key Derivation Functions (KDFs) with inadequate salt sizes.
 * 
 * This rule detects KDF implementations that:
 * 1. Utilize os.urandom with a static salt size parameter less than 16 bytes
 * 2. Employ non-constant values for salt size configuration that cannot be statically verified
 * @id py/kdf-small-salt-size
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation keyDerivationOp, DataFlow::Node saltSizeParamSource, API::CallNode urandomInvocation, string securityWarning
where
  // Basic KDF operation validation
  keyDerivationOp.requiresSalt() and
  
  // os.urandom call identification and verification
  API::moduleImport("os").getMember("urandom").getACall() = urandomInvocation and
  urandomInvocation = keyDerivationOp.getSaltConfigSrc() and
  
  // Salt size parameter tracing
  saltSizeParamSource = CryptoUtils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size")) and
  
  // Salt size evaluation
  (
    // Non-static salt size configuration
    not exists(saltSizeParamSource.asExpr().(IntegerLiteral).getValue()) and
    securityWarning = "Salt size configuration is not statically verifiable. "
    or
    // Insufficient static salt size (< 16 bytes)
    saltSizeParamSource.asExpr().(IntegerLiteral).getValue() < 16 and
    securityWarning = "Salt size is insufficient. "
  )
select keyDerivationOp,
  securityWarning + "Minimum salt size must be 16 bytes. os.urandom Configuration: $@, Size Parameter: $@", 
  urandomInvocation, 
  urandomInvocation.toString(), 
  saltSizeParamSource, 
  saltSizeParamSource.toString()