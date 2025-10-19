/**
 * @name Insufficient KDF Salt Length
 * @description Identifies key derivation functions using salt values below security requirements.
 * 
 * This query detects cryptographic key derivation operations that utilize salt values
 * with inadequate length. It flags scenarios where salt size is either below 128 bits (16 bytes)
 * or cannot be statically determined during analysis.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOp, DataFlow::Node saltSizeSrc, API::CallNode urandomCall, string alertMsg
where
  // Validate KDF operation requires salt parameter
  kdfOp.requiresSalt() and
  
  // Identify salt configuration via os.urandom calls
  exists(API::CallNode saltConfigCall |
    // Verify os.urandom module and method
    API::moduleImport("os").getMember("urandom").getACall() = saltConfigCall and
    // Establish connection to KDF salt configuration
    saltConfigCall = kdfOp.getSaltConfigSrc() and
    // Track specific urandom invocation
    urandomCall = saltConfigCall and
    // Trace size parameter origin
    saltSizeSrc = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size"))
  ) and
  
  // Evaluate salt size against security thresholds
  (
    // Case 1: Non-static salt size (dynamic value)
    not exists(saltSizeSrc.asExpr().(IntegerLiteral).getValue()) and
    alertMsg = "Salt size is not statically verifiable. "
    or
    // Case 2: Salt size below minimum requirement
    saltSizeSrc.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMsg = "Salt size is below minimum requirement. "
  )
select kdfOp,
  alertMsg + "Minimum 16 bytes required. os.urandom Config: $@, Size Config: $@", 
  urandomCall, urandomCall.toString(), 
  saltSizeSrc, saltSizeSrc.toString()