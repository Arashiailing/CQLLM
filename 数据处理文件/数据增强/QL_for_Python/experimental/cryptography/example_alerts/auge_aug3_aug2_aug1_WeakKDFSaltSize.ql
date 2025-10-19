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

from KeyDerivationOperation kdfOp, DataFlow::Node saltSizeParamSrc, API::CallNode urandomInvocation, string alertMsg
where
  // Step 1: Identify KDF operations requiring salt configuration
  kdfOp.requiresSalt() and
  
  // Step 2: Trace salt configuration to os.urandom calls and extract size parameter source
  exists(API::CallNode saltConfigCall |
    // Verify salt configuration uses os.urandom
    API::moduleImport("os").getMember("urandom").getACall() = saltConfigCall and
    saltConfigCall = kdfOp.getSaltConfigSrc() and
    urandomInvocation = saltConfigCall and
    // Resolve ultimate source of size parameter
    saltSizeParamSrc = Utils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size"))
  ) and
  
  // Step 3: Evaluate salt size compliance and generate appropriate alert
  (
    // Case A: Non-static salt size (cannot be determined at analysis time)
    not exists(saltSizeParamSrc.asExpr().(IntegerLiteral).getValue()) and
    alertMsg = "Salt configuration does not use a statically verifiable size. "
    or
    // Case B: Static salt size below minimum requirement (16 bytes)
    saltSizeParamSrc.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMsg = "Salt configuration uses an insufficiently large size. "
  )
select kdfOp,
  alertMsg + "Salt size must be a minimum of 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomInvocation, urandomInvocation.toString(), 
  saltSizeParamSrc, saltSizeParamSrc.toString()