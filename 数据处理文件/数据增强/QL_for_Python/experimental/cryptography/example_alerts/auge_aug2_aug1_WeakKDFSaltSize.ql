/**
 * @name Small KDF salt length.
 * @description Detects KDF operations with insufficient salt size.
 * 
 * This query identifies cryptographic key derivation functions (KDFs) that use
 * salt values with insufficient length. It flags cases where the salt size is
 * either less than 128 bits (16 bytes) or cannot be statically verified.
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
  // Condition 1: Ensure the KDF operation requires salt
  kdfOperation.requiresSalt() and
  
  // Condition 2: Identify os.urandom calls used for salt configuration
  exists(API::CallNode saltConfigurationCall |
    // Verify the call is to os.urandom
    API::moduleImport("os").getMember("urandom").getACall() = saltConfigurationCall and
    // Link the salt configuration to the KDF operation
    saltConfigurationCall = kdfOperation.getSaltConfigSrc() and
    // Track the specific urandom invocation
    urandomCall = saltConfigurationCall and
    // Trace the source of the size parameter
    saltSizeSource = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size"))
  ) and
  
  // Condition 3: Evaluate salt size for security compliance
  (
    // Subcase 3.1: Salt size is not statically verifiable (dynamic value)
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Salt config is not a statically verifiable size. "
    or
    // Subcase 3.2: Salt size is below the minimum requirement (16 bytes)
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMessage = "Salt config is insufficiently large. "
  )
select kdfOperation,
  warningMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSource, saltSizeSource.toString()