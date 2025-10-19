/**
 * @name Insufficient KDF Salt Size
 * @description Identifies Key Derivation Function (KDF) implementations with 
 * insufficient salt sizes. Salts must be at least 128 bits (16 bytes) in length.
 *
 * This query detects two critical security issues:
 * - Salt size configuration below the 128-bit security threshold
 * - Salt size that cannot be statically determined during analysis
 * 
 * The analysis focuses on salt configurations using os.urandom() calls,
 * which are commonly used for generating cryptographically secure random salts.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation keyDerivationOp, 
     DataFlow::Node saltSizeParam, 
     API::CallNode urandomCall, 
     string alertMessage
where
  // Basic validation: KDF operation must require salt parameter
  keyDerivationOp.requiresSalt() and
  
  // Salt source verification: must be from os.urandom()
  urandomCall = keyDerivationOp.getSaltConfigSrc() and
  urandomCall = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Parameter tracing: identify the source of salt size configuration
  saltSizeParam = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Vulnerability detection: check for insufficient or non-static salt size
  (
    // Case 1: Salt size is not statically determinable
    not exists(saltSizeParam.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt config is not a statically verifiable size. "
    or
    // Case 2: Salt size is below the 16-byte minimum
    saltSizeParam.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt config is insufficiently large. "
  )

select keyDerivationOp,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomCall,
  urandomCall.toString(), 
  saltSizeParam, 
  saltSizeParam.toString()