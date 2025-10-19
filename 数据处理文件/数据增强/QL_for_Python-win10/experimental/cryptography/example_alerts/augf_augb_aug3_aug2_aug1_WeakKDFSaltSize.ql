/**
 * @name Insufficient KDF Salt Length Detection
 * @description Identifies cryptographic key derivation functions (KDFs) 
 * that use salt values with insufficient length. This query flags KDF operations 
 * where the salt size is less than 16 bytes (128 bits) or cannot be statically determined.
 * 
 * The analysis involves:
 *   - Locating KDF operations that require salt configuration.
 *   - Tracing the salt source to os.urandom calls to determine the salt size parameter.
 *   - Validating the salt size against cryptographic best practices (minimum 16 bytes).
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOperation, 
     DataFlow::Node saltSizeSource, 
     API::CallNode urandomCall, 
     string warningMessage
where
  // Validate KDF operation requires salt configuration
  kdfOperation.requiresSalt() and
  
  // Trace salt configuration through os.urandom calls
  exists(API::CallNode saltConfigSource |
    // Salt must originate from os.urandom
    API::moduleImport("os").getMember("urandom").getACall() = saltConfigSource and
    saltConfigSource = kdfOperation.getSaltConfigSrc() and
    urandomCall = saltConfigSource and
    // Extract salt size parameter from urandom call
    saltSizeSource = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size"))
  ) and
  
  // Generate warning based on salt size validation
  (
    // Case 1: Salt size cannot be statically verified
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Salt configuration does not use a statically verifiable size. "
    or
    // Case 2: Salt size is below cryptographic minimum
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMessage = "Salt configuration uses an insufficiently large size. "
  )
select kdfOperation,
  warningMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSource, saltSizeSource.toString()