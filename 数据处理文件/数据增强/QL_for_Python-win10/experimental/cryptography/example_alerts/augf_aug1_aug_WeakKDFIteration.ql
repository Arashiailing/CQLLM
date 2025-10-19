/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with inadequate iteration counts.
 * Cryptographic keys derived from user inputs (e.g., passwords) must use high iteration counts
 * (minimum 100,000 iterations) to resist brute force attacks.
 *
 * This query detects two vulnerability patterns:
 * 1. Explicit iteration count constants below 100,000
 * 2. Iteration counts that cannot be statically verified
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

// Select vulnerable key derivation operations
from KeyDerivationOperation keyDerivationOp, string warningMessage, DataFlow::Node iterationSource
where
  // Filter operations requiring iteration configuration
  keyDerivationOp.requiresIteration() and
  // Identify iteration count configuration source
  iterationSource = keyDerivationOp.getIterationSizeSrc() and
  (
    // Case 1: Explicit iteration count below security threshold
    exists(int iterationValue |
      iterationSource.asExpr() instanceof IntegerLiteral and
      iterationValue = iterationSource.asExpr().(IntegerLiteral).getValue() and
      iterationValue < 100000 and
      warningMessage = "Insufficient iteration count detected. "
    )
    or
    // Case 2: Non-constant iteration count (unverifiable)
    not iterationSource.asExpr() instanceof IntegerLiteral and
    warningMessage = "Iteration count cannot be statically verified. "
  )
select 
  // Report vulnerable operation with contextual warning
  keyDerivationOp, warningMessage + "Minimum required iteration count is 100000. Configuration source: $@",
  iterationSource.asExpr(), iterationSource.asExpr().toString()