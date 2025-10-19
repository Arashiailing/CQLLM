/**
 * @name Insufficient KDF Salt Length
 * @description Identifies key derivation functions using salt values with inadequate length.
 * 
 * This query detects cryptographic key derivation functions (KDFs) that utilize
 * salt values with insufficient length. It highlights instances where the salt size
 * is either below 128 bits (16 bytes) or cannot be statically determined.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOperation, DataFlow::Node saltSizeSource, API::CallNode urandomCall, string warningMsg
where
  // Identify KDF operations that require salt
  kdfOperation.requiresSalt() and
  
  // Trace salt configuration to os.urandom calls and extract size parameter source
  exists(API::CallNode saltConfigurationCall |
    API::moduleImport("os").getMember("urandom").getACall() = saltConfigurationCall and
    saltConfigurationCall = kdfOperation.getSaltConfigSrc() and
    urandomCall = saltConfigurationCall and
    saltSizeSource = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size"))
  ) and
  
  // Validate salt size requirements
  (
    // Check for non-statically verifiable salt size
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Salt configuration uses non-statically verifiable size. "
    or
    // Check for insufficient salt size (less than 16 bytes)
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMsg = "Salt configuration uses insufficiently large size. "
  )
select kdfOperation,
  warningMsg + "Salt size must be a minimum of 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSource, saltSizeSource.toString()