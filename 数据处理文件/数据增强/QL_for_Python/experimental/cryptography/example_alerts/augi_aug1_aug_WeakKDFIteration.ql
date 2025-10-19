/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with insufficient iteration counts.
 * Cryptographic keys derived from user inputs (e.g., passwords) must utilize a high iteration count
 * (minimum 100,000 iterations) to mitigate brute force attacks.
 *
 * This query detects two security concerns:
 * 1. Constant iteration count values below the 100,000 threshold
 * 2. Iteration count values that cannot be statically determined
 * @kind problem
 * @id py/kdf-low-iteration-count
 * @problem.severity error
 * @precision high
 */

// Import standard Python analysis library
import python
// Import experimental cryptography concepts for key derivation operations
import experimental.cryptography.Concepts
// Import utility functions for cryptography analysis, aliased as CryptoUtils
private import experimental.cryptography.utils.Utils as CryptoUtils

// Select key derivation operations with insufficient iteration counts
from KeyDerivationOperation keyDerivationOp, string warningMessage, DataFlow::Node iterationSource
where
  // Filter operations that require iteration configuration
  keyDerivationOp.requiresIteration() and
  // Extract the source of iteration count configuration
  iterationSource = keyDerivationOp.getIterationSizeSrc()
  and
  (
    // Check for explicitly defined iteration count below security threshold
    exists(IntegerLiteral literal |
      literal = iterationSource.asExpr() and
      literal.getValue() < 100000 and
      warningMessage = "Insufficient iteration count detected. "
    )
    or
    // Check for iteration count that cannot be statically verified
    not iterationSource.asExpr() instanceof IntegerLiteral and
    warningMessage = "Iteration count cannot be statically verified. "
  )
select 
  // Report the key derivation operation with appropriate warning message
  keyDerivationOp, warningMessage + "Minimum required iteration count is 100000. Configuration source: $@",
  iterationSource.asExpr(), iterationSource.asExpr().toString()