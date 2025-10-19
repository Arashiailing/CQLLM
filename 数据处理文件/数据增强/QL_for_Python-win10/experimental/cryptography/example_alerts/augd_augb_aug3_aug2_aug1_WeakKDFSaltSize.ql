/**
 * @name Inadequate KDF Salt Length Detection
 * @description Identifies cryptographic key derivation functions (KDFs) 
 * that utilize salt values with insufficient length. This query flags instances 
 * where the salt size is either less than 128 bits (16 bytes) or cannot be 
 * statically determined during analysis.
 * 
 * The analysis locates KDF operations that require salt configuration, traces 
 * the salt configuration path through os.urandom function calls, and validates 
 * the salt size parameters against established cryptographic security standards.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation keyDerivationFunc, 
     DataFlow::Node saltSizeParameter, 
     API::CallNode urandomCall, 
     string alertMessage
where
  // Verify that the key derivation function requires salt configuration
  keyDerivationFunc.requiresSalt() and
  
  // Trace salt configuration through os.urandom calls
  exists(API::CallNode saltConfigurationCall |
    // Salt configuration must use os.urandom
    saltConfigurationCall = API::moduleImport("os").getMember("urandom").getACall() and
    saltConfigurationCall = keyDerivationFunc.getSaltConfigSrc() and
    urandomCall = saltConfigurationCall and
    // Extract the size parameter from urandom call
    saltSizeParameter = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size"))
  ) and
  
  // Evaluate salt size against security requirements
  (
    // Scenario 1: Salt size is not statically determinable
    not exists(saltSizeParameter.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt configuration does not use a statically verifiable size. "
    or
    // Scenario 2: Salt size is below the minimum security threshold
    saltSizeParameter.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt configuration uses an insufficiently large size. "
  )
select keyDerivationFunc,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeParameter, saltSizeParameter.toString()