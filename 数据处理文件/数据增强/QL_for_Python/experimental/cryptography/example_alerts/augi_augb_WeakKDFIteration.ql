/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description When deriving cryptographic keys from user-provided inputs such as password,
 * use sufficient iteration count (at least 100k).
 *
 * This query identifies key derivation operations that either use iteration counts below 10000
 * or rely on non-statically-verifiable iteration configurations.
 * @kind problem
 * @id py/kdf-low-iteration-count
 * @problem.severity error
 * @precision high
 */

// Import Python standard library
import python
// Import experimental cryptography concepts
import experimental.cryptography.Concepts
// Private import of experimental cryptography utilities, aliased as Utils
private import experimental.cryptography.utils.Utils as Utils

// Select key derivation operations, alert messages, and iteration configuration sources
from KeyDerivationOperation kdfOp, string alertMsg, DataFlow::Node iterSrc
where
  // Filter operations requiring iteration configuration
  kdfOp.requiresIteration() and
  // Identify iteration count configuration source
  iterSrc = kdfOp.getIterationSizeSrc() and
  (
    // Case 1: Literal integer iteration count below threshold
    exists(int iterCount | 
      iterCount = iterSrc.asExpr().(IntegerLiteral).getValue() and
      iterCount < 10000
    ) and
    alertMsg = "Iteration count is too low. "
    // Case 2: Non-statically-verifiable iteration count
    or
    not exists(iterSrc.asExpr().(IntegerLiteral).getValue()) and
    alertMsg = "Iteration count is not a statically verifiable size. "
  )
select 
  // Output key derivation operation, alert message, and iteration configuration details
  kdfOp, alertMsg + "Iteration count must be a minimum of 10000. Iteration Config: $@",
  iterSrc.asExpr(), iterSrc.asExpr().toString()