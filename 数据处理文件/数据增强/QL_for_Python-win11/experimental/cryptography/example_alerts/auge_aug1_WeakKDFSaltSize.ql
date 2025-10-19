/**
 * @name Insufficient KDF Salt Length
 * @description Identifies key derivation functions using salt with inadequate size.
 * 
 * Detects KDF operations where a constant value flows to a salt length parameter
 * that is below 128 bits (16 bytes), or when the salt size cannot be
 * determined through static analysis.
 * @kind problem
 * @id py/kdf-small-salt-size
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation keyDerivFunc, DataFlow::Node saltSizeSource, API::CallNode urandomInvocation, string alertMessage
where
  // Focus on KDF operations that require salt parameter
  keyDerivFunc.requiresSalt() and
  
  // Locate os.urandom calls utilized for salt configuration
  API::moduleImport("os").getMember("urandom").getACall() = urandomInvocation and
  urandomInvocation = keyDerivFunc.getSaltConfigSrc() and
  
  // Determine the origin of the size parameter value
  saltSizeSource = Utils::getUltimateSrcFromApiNode(urandomInvocation.getParameter(0, "size")) and
  
  // Evaluate salt size for security requirements
  (
    // Scenario 1: Salt size cannot be statically verified
    not exists(saltSizeSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Salt configuration size cannot be statically verified. "
    or
    // Scenario 2: Salt size is below the minimum requirement
    saltSizeSource.asExpr().(IntegerLiteral).getValue() < 16 and
    alertMessage = "Salt configuration size is below minimum requirement. "
  )
select keyDerivFunc,
  alertMessage + "Salt size must be at least 16 bytes. os.urandom Configuration: $@, Size Parameter: $@", 
  urandomInvocation, urandomInvocation.toString(), 
  saltSizeSource, saltSizeSource.toString()