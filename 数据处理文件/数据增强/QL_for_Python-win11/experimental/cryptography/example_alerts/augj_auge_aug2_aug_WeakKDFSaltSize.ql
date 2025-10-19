/**
 * @name Insufficient KDF Salt Size
 * @description Identifies Key Derivation Function (KDF) implementations with salt sizes
 * below the security minimum of 128 bits (16 bytes).
 *
 * This query detects two critical security vulnerabilities:
 * 1. Salt size explicitly configured below the 16-byte threshold
 * 2. Salt size determined dynamically (preventing static verification)
 * 
 * Focuses specifically on salt generation using Python's os.urandom() function.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

// Locate KDF operations with vulnerable salt configurations
from KeyDerivationOperation kdfOperation, 
     DataFlow::Node saltSizeParam, 
     API::CallNode urandomInvocation, 
     string warningMsg
where
  // Ensure the KDF operation requires a salt parameter
  kdfOperation.requiresSalt() and
  
  // Validate that salt configuration uses os.urandom
  urandomInvocation = kdfOperation.getSaltConfigSrc() and
  urandomInvocation = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Trace the salt size parameter back to its origin
  saltSizeParam = CryptoUtils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size")) and
  
  // Identify security vulnerability patterns
  (
    // Case 1: Dynamic salt size (cannot be statically verified)
    not exists(saltSizeParam.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Salt size is not statically determinable. "
    or
    // Case 2: Salt size below minimum security threshold
    saltSizeParam.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMsg = "Salt size is below security minimum. "
  )

// Generate security alert with detailed context
select kdfOperation,
  warningMsg + "Minimum required salt size is 16 bytes. os.urandom Configuration: $@, Size Parameter: $@", 
  urandomInvocation,
  urandomInvocation.toString(), 
  saltSizeParam, 
  saltSizeParam.toString()