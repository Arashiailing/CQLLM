/**
 * @name Insufficient KDF Salt Size
 * @description Key Derivation Function (KDF) salts must be at least 128 bits (16 bytes) in length.
 *
 * This analysis identifies two critical security vulnerabilities in KDF implementations:
 * 1. Salt size configuration that falls below the 128-bit security threshold
 * 2. Salt size that cannot be statically determined during code analysis
 * 
 * The query specifically targets salt configurations implemented through os.urandom() calls,
 * which are commonly used for generating cryptographically secure random salts.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

// Define the main query logic to identify vulnerable KDF configurations
from KeyDerivationOperation kdfOperation, 
     DataFlow::Node saltSizeSource, 
     API::CallNode urandomInvocation, 
     string warningMessage
where
  // Validate that the KDF operation requires a salt parameter
  kdfOperation.requiresSalt() and
  
  // Ensure the salt configuration originates from os.urandom function
  urandomInvocation = kdfOperation.getSaltConfigSrc() and
  urandomInvocation = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Trace the salt size parameter to its ultimate source for analysis
  saltSizeSource = CryptoUtils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size")) and
  
  // Identify two distinct vulnerability patterns in salt configuration
  (
    // Vulnerability Pattern 1: Non-static salt size (runtime-determined)
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Salt config is not a statically verifiable size. "
    or
    // Vulnerability Pattern 2: Salt size below 16-byte minimum requirement
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMessage = "Salt config is insufficiently large. "
  )

// Generate security findings with detailed contextual information
select kdfOperation,
  warningMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomInvocation,
  urandomInvocation.toString(), 
  saltSizeSource, 
  saltSizeSource.toString()