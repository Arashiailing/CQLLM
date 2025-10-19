/**
 * @name Insufficient KDF Salt Length Detection
 * @description Detects key derivation functions using salt values with inadequate length.
 * 
 * This analysis identifies cryptographic key derivation functions (KDFs) that employ
 * salt values with insufficient length. It flags cases where the salt size is
 * either less than 128 bits (16 bytes) or cannot be statically determined.
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
  // Identify KDF operations that require salt configuration
  kdfOperation.requiresSalt() and
  
  // Trace salt configuration to os.urandom calls and extract size parameter source
  exists(API::CallNode saltConfiguration |
    // Verify salt configuration uses os.urandom
    API::moduleImport("os").getMember("urandom").getACall() = saltConfiguration and
    saltConfiguration = kdfOperation.getSaltConfigSrc() and
    urandomCall = saltConfiguration and
    // Resolve the ultimate source of the size parameter
    saltSizeSource = CryptoUtils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size"))
  ) and
  
  // Evaluate salt size compliance and generate appropriate warning
  (
    // Case 1: Non-static salt size (cannot be determined at analysis time)
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Salt configuration does not use a statically verifiable size. "
    or
    // Case 2: Static salt size below minimum requirement (16 bytes)
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMessage = "Salt configuration uses an insufficiently large size. "
  )
select kdfOperation,
  warningMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSource, saltSizeSource.toString()