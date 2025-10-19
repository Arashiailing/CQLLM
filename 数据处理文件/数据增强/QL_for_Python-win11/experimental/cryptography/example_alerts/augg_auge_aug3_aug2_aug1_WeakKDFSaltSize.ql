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

from KeyDerivationOperation keyDerivationOp, DataFlow::Node saltSizeSource, API::CallNode urandomCall, string alertMessage
where
  // First, identify KDF operations that require salt configuration
  keyDerivationOp.requiresSalt() and
  
  // Next, trace salt configuration to os.urandom calls and extract the size parameter source
  exists(API::CallNode saltConfigurationCall |
    // Verify that the salt configuration uses os.urandom
    API::moduleImport("os").getMember("urandom").getACall() = saltConfigurationCall and
    saltConfigurationCall = keyDerivationOp.getSaltConfigSrc() and
    urandomCall = saltConfigurationCall and
    // Resolve the ultimate source of the size parameter
    saltSizeSource = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size"))
  ) and
  
  // Finally, evaluate salt size compliance and generate an appropriate alert message
  (
    // Case 1: Salt size is not statically determinable
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt configuration does not use a statically verifiable size. "
    or
    // Case 2: Salt size is below the minimum requirement of 16 bytes
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt configuration uses an insufficiently large size. "
  )
select keyDerivationOp,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSource, saltSizeSource.toString()