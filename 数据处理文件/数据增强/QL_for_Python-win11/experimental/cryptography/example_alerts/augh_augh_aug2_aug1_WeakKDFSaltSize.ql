/**
 * @name Insufficient KDF Salt Length
 * @description Detects key derivation functions using salt values with inadequate length.
 * 
 * This query identifies cryptographic key derivation functions (KDFs) that use
 * salt values with insufficient length. It flags cases where the salt size
 * is either below 128 bits (16 bytes) or cannot be statically determined.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation keyDerivFunc, DataFlow::Node saltSizeParamSrc, API::CallNode urandomInvocation, string alertMessage
where
  // Ensure we're only analyzing KDF operations that require salt
  keyDerivFunc.requiresSalt() and
  
  // Establish connection between KDF operation and os.urandom call used for salt generation
  exists(API::CallNode saltConfigCall |
    // Verify the call is to os.urandom
    API::moduleImport("os").getMember("urandom").getACall() = saltConfigCall and
    // Confirm this urandom call is used for salt configuration in the KDF
    saltConfigCall = keyDerivFunc.getSaltConfigSrc() and
    // Assign the urandom call for later reference in the output
    urandomInvocation = saltConfigCall and
    // Trace the source of the size parameter passed to urandom
    saltSizeParamSrc = Utils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size"))
  ) and
  
  // Evaluate salt size adequacy
  (
    // Case 1: Salt size cannot be statically verified
    not exists(saltSizeParamSrc.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt configuration uses non-statically verifiable size. "
    or
    // Case 2: Salt size is insufficient (less than 16 bytes)
    saltSizeParamSrc.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt configuration uses insufficiently large size. "
  )
select keyDerivFunc,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomInvocation, urandomInvocation.toString(), 
  saltSizeParamSrc, saltSizeParamSrc.toString()