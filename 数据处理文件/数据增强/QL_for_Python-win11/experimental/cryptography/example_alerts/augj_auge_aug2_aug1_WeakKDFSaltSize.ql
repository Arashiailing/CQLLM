/**
 * @name Small KDF salt length.
 * @description Identifies KDF operations using insufficient salt sizes.
 * 
 * This query detects cryptographic key derivation functions (KDFs) that utilize
 * salt values with inadequate length. It flags scenarios where salt size is
 * either below 128 bits (16 bytes) or cannot be statically determined.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOp, DataFlow::Node saltSizeParamSrc, API::CallNode urandomNode, string warningMsg
where
  // Validate KDF requires salt configuration
  kdfOp.requiresSalt() and
  
  // Identify os.urandom calls used for salt generation
  exists(API::CallNode saltCfgCall |
    saltCfgCall = API::moduleImport("os").getMember("urandom").getACall() and
    saltCfgCall = kdfOp.getSaltConfigSrc() and
    urandomNode = saltCfgCall and
    saltSizeParamSrc = Utils::getUltimateSrcFromApiNode(urandomNode.getParameter(0, "size"))
  ) and
  
  // Evaluate salt size security compliance
  (
    // Case 1: Non-static salt size configuration
    not exists(saltSizeParamSrc.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Salt config is not a statically verifiable size. "
    or
    // Case 2: Insufficient salt size (<16 bytes)
    saltSizeParamSrc.asExpr().(IntegerLiteral).getValue() < 16 and
    warningMsg = "Salt config is insufficiently large. "
  )
select kdfOp,
  warningMsg + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomNode, urandomNode.toString(), 
  saltSizeParamSrc, saltSizeParamSrc.toString()