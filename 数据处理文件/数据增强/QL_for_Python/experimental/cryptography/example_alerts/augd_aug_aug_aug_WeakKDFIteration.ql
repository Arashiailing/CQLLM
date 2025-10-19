/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with insufficient iteration counts.
 * 
 * Detects KDF operations using iteration counts below 10000 or when the iteration count
 * cannot be statically determined from the code. This is critical for security as low
 * iteration counts make key derivation vulnerable to brute force attacks.
 * @kind problem
 * @id py/kdf-low-iteration-count
 * @problem.severity error
 * @precision high
 */

// Import standard Python analysis framework
import python
// Import cryptographic concepts for key derivation analysis
import experimental.cryptography.Concepts
// Import utility functions for cryptographic analysis
private import experimental.cryptography.utils.Utils as CryptoUtils

// Query body: Identify vulnerable key derivation operations
from KeyDerivationOperation keyDerivationOp, string warningMessage, DataFlow::Node iterationCountSource
where
  // Filter for KDF operations that require iteration parameters
  keyDerivationOp.requiresIteration() and
  // Identify the source of the iteration count configuration
  iterationCountSource = keyDerivationOp.getIterationSizeSrc() and
  // Check for either insufficient static iteration or non-static iteration
  (
    // Case 1: Explicit integer literal with insufficient value
    exists(IntegerLiteral iterationLiteral | 
      iterationLiteral = iterationCountSource.asExpr() and
      iterationLiteral.getValue() < 10000 and
      warningMessage = "Iteration count is too low. "
    )
    // Case 2: Non-statically determinable iteration count
    or
    not exists(iterationCountSource.asExpr().(IntegerLiteral)) and
    warningMessage = "Iteration count is not a statically verifiable size. "
  )
select 
  // Output format: operation, warning message with iteration config reference, and the config expression
  keyDerivationOp, warningMessage + "Iteration count must be a minimum of 10000. Iteration Config: $@",
  iterationCountSource.asExpr(), iterationCountSource.asExpr().toString()