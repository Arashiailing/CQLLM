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

from KeyDerivationOperation keyDerivationOp, DataFlow::Node sizeParamSource, API::CallNode urandomInvocation, string alertMessage
where
  // Filter for KDF operations that require salt
  keyDerivationOp.requiresSalt() and
  
  // Identify os.urandom calls used for salt configuration and trace the size parameter source
  exists(API::CallNode saltConfigCall |
    API::moduleImport("os").getMember("urandom").getACall() = saltConfigCall and
    saltConfigCall = keyDerivationOp.getSaltConfigSrc() and
    urandomInvocation = saltConfigCall and
    sizeParamSource = Utils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size"))
  ) and
  
  // Check for insufficient or non-static salt size
  (
    // Case 1: Salt size is not statically verifiable
    not exists(sizeParamSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt config is not a statically verifiable size. "
    or
    // Case 2: Salt size is less than required minimum
    sizeParamSource.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt config is insufficiently large. "
  )
select keyDerivationOp,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Config: $@, Size Config: $@", 
  urandomInvocation, urandomInvocation.toString(), 
  sizeParamSource, sizeParamSource.toString()