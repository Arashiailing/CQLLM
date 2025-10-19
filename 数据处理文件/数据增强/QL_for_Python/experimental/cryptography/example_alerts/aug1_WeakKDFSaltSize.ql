/**
 * @name Small KDF salt length.
 * @description Detects KDF operations with insufficient salt size.
 * 
 * Identifies cases where a constant value traces to a salt length sink
 * that is less than 128 bits (16 bytes), or when the salt size cannot be
 * statically verified.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOp, DataFlow::Node sizeConfigSrc, API::CallNode urandomCall, string warningMsg
where
  // Filter for KDF operations that require salt
  kdfOp.requiresSalt() and
  
  // Identify os.urandom calls used for salt configuration
  API::moduleImport("os").getMember("urandom").getACall() = urandomCall and
  urandomCall = kdfOp.getSaltConfigSrc() and
  
  // Trace the ultimate source of the size parameter
  sizeConfigSrc = Utils::getUltimateSrcFromApiNode(urandomCall.getParameter(0, "size")) and
  
  // Check for insufficient or non-static salt size
  (
    // Case 1: Salt size is not statically verifiable
    not exists(sizeConfigSrc.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Salt config is not a statically verifiable size. "
    or
    // Case 2: Salt size is less than required minimum
    sizeConfigSrc.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMsg = "Salt config is insufficiently large. "
  )
select kdfOp,
  warningMsg + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomCall, urandomCall.toString(), 
  sizeConfigSrc, sizeConfigSrc.toString()