/**
 * @name Insufficient KDF Salt Length Detection
 * @description Identifies key derivation functions with inadequate salt size.
 * 
 * This query detects cryptographic key derivation functions (KDFs) that utilize
 * salt values with insufficient length. It flags instances where the salt size is
 * either below 128 bits (16 bytes) or cannot be statically determined.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOperation, DataFlow::Node saltSizeSource, API::CallNode urandomCall, string warningMessage
where
  // Filter for KDF operations that require salt
  kdfOperation.requiresSalt() and
  
  // Identify os.urandom calls used for salt configuration and trace the size parameter source
  exists(API::CallNode saltConfigurationCall |
    API::moduleImport("os").getMember("urandom").getACall() = saltConfigurationCall and
    saltConfigurationCall = kdfOperation.getSaltConfigSrc() and
    urandomCall = saltConfigurationCall and
    saltSizeSource = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size"))
  ) and
  
  // Determine warning message based on salt size verification
  (
    // Case 1: Salt size is not statically verifiable
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Salt configuration does not use a statically verifiable size. "
    or
    // Case 2: Salt size is less than required minimum
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMessage = "Salt configuration uses an insufficiently large size. "
  )
select kdfOperation,
  warningMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSource, saltSizeSource.toString()