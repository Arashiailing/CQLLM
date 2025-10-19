/**
 * @name Insufficient KDF Salt Size
 * @description Identifies Key Derivation Function (KDF) salt configurations that fall below the minimum security requirement of 128 bits (16 bytes).
 *
 * This security rule detects two critical vulnerabilities in salt configuration:
 * 1. Explicit salt size settings that are less than the recommended 128 bits
 * 2. Salt size parameters that cannot be statically determined during static analysis
 * 
 * The analysis specifically targets salt configurations that utilize the os.urandom() function,
 * which is commonly used for generating cryptographically secure random values.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

// Identify KDF operations with vulnerable salt configurations
from KeyDerivationOperation kdfOperation, DataFlow::Node saltSizeNode, API::CallNode urandomCall, string securityIssue
where
  // Verify that the KDF operation requires salt configuration
  kdfOperation.requiresSalt() and
  
  // Ensure salt source is from os.urandom() function call
  urandomCall = kdfOperation.getSaltConfigSrc() and
  urandomCall = API::moduleImport("os").getMember("urandom").getACall() and
  
  // Trace the salt size parameter to its origin
  saltSizeNode = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Detect salt configuration vulnerabilities
  (
    // Vulnerability 1: Salt size cannot be statically determined
    not exists(saltSizeNode.asExpr().(IntegerLiteral).getValue()) and
    securityIssue = "Salt configuration size is not statically verifiable. "
    or
    // Vulnerability 2: Salt size is below minimum security threshold
    saltSizeNode.asExpr().(IntegerLiteral).getValue() < 16 and
    securityIssue = "Salt configuration size is below minimum requirement. "
  )

// Generate security findings with detailed contextual information
select kdfOperation,
  securityIssue + "Salt size must be at least 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomCall,
  urandomCall.toString(), 
  saltSizeNode, 
  saltSizeNode.toString()