/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description When deriving cryptographic keys from user-provided inputs such as password,
 * use sufficient iteration count (at least 100k).
 *
 * This query will alert if the iteration count is less than 10000 (i.e., a constant <100000 is observed)
 * or if the source for the iteration count is not known statically.
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
from KeyDerivationOperation keyDerivationOp, string alertMessage, DataFlow::Node iterationSource
where
  // Filter for operations that require iteration
  keyDerivationOp.requiresIteration() and
  // Get the source of the iteration size configuration
  iterationSource = keyDerivationOp.getIterationSizeSrc() and
  (
    // Case 1: Check if iteration count is a literal integer and below threshold
    exists(int iterationCount | 
      iterationCount = iterationSource.asExpr().(IntegerLiteral).getValue() and
      iterationCount < 10000
    ) and
    alertMessage = "Iteration count is too low. "
    // Case 2: Check if iteration count is not a statically verifiable literal
    or
    not exists(iterationSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Iteration count is not a statically verifiable size. "
  )
select 
  // Output the key derivation operation, alert message, and iteration configuration details
  keyDerivationOp, alertMessage + "Iteration count must be a minimum of 10000. Iteration Config: $@",
  iterationSource.asExpr(), iterationSource.asExpr().toString()