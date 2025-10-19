/**
 * @name Insufficient KDF Salt Length
 * @description Identifies key derivation functions utilizing salt values with inadequate length.
 * 
 * This query detects cryptographic key derivation functions (KDFs) that employ
 * salt values with insufficient length. It flags instances where the salt size
 * is either below 128 bits (16 bytes) or cannot be statically determined.
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
  
  // Establish relationship between KDF operation and os.urandom call for salt generation
  exists(API::CallNode saltGenerationCall |
    // Verify the call is to os.urandom
    API::moduleImport("os").getMember("urandom").getACall() = saltGenerationCall and
    // Confirm this urandom call is used for salt configuration in the KDF
    saltGenerationCall = kdfOperation.getSaltConfigSrc() and
    // Assign the urandom call for later reference in the output
    urandomCall = saltGenerationCall and
    // Trace the origin of the size parameter passed to urandom
    saltSizeSource = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size"))
  ) and
  
  // Check if salt size is inadequate or indeterminate
  (
    // Case 1: Salt size cannot be statically verified
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Salt configuration uses non-statically verifiable size. "
    or
    // Case 2: Salt size is insufficient (less than 16 bytes)
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMessage = "Salt configuration uses insufficiently large size. "
  )
select kdfOperation,
  warningMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSource, saltSizeSource.toString()