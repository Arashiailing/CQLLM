/**
 * @name Insufficient KDF Salt Length Detection
 * @description Identifies key derivation functions with inadequate salt size.
 * 
 * Detects cryptographic key derivation functions (KDFs) that use salt values
 * with insufficient length. Flags cases where salt size is either below 128 bits
 * (16 bytes) or cannot be statically determined.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOp, DataFlow::Node sizeParamSource, API::CallNode urandomInvocation, string alertMessage
where
  // Ensure KDF operation requires salt configuration
  kdfOp.requiresSalt() and
  
  // Identify os.urandom calls used for salt generation and trace size parameter
  exists(API::CallNode saltConfigCall |
    saltConfigCall = API::moduleImport("os").getMember("urandom").getACall() and
    saltConfigCall = kdfOp.getSaltConfigSrc() and
    urandomInvocation = saltConfigCall and
    sizeParamSource = Utils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size"))
  ) and
  
  // Generate appropriate alert based on salt size validation
  (
    // Case 1: Salt size cannot be statically verified
    not exists(sizeParamSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt configuration does not use a statically verifiable size. "
    or
    // Case 2: Salt size is below minimum requirement
    sizeParamSource.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt configuration uses an insufficiently large size. "
  )
select kdfOp,
  alertMessage + "Salt size must be a minimum of 16 (bytes). os.urandom Configuration: $@, Size Parameter: $@", 
  urandomInvocation, urandomInvocation.toString(), 
  sizeParamSource, sizeParamSource.toString()