/**
 * @name Insufficient KDF Salt Length Detection
 * @description Identifies key derivation functions using salt values with inadequate length.
 * 
 * This analysis detects cryptographic key derivation functions (KDFs) that utilize
 * salt values with insufficient length. It flags instances where the salt size is
 * either below 128 bits (16 bytes) or cannot be statically determined.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation kdfOperation, DataFlow::Node saltSizeSource, API::CallNode urandomCall, string warningMessage
where
  // Identify KDF operations that require salt for security
  kdfOperation.requiresSalt() and
  
  // Locate os.urandom invocations used for salt generation and trace the size parameter
  exists(API::CallNode saltGenerationCall |
    API::moduleImport("os").getMember("urandom").getACall() = saltGenerationCall and
    saltGenerationCall = kdfOperation.getSaltConfigSrc() and
    urandomCall = saltGenerationCall and
    saltSizeSource = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size"))
  ) and
  
  // Evaluate salt size for security compliance
  (
    // Scenario 1: Salt size cannot be statically verified
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Salt size cannot be statically verified. "
    or
    // Scenario 2: Salt size is below the security threshold
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMessage = "Salt size is below the minimum required. "
  )
select kdfOperation,
  warningMessage + "Salt size must be at least 16 bytes. os.urandom Configuration: $@, Size Parameter: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSource, saltSizeSource.toString()