/**
 * @name Insufficient KDF Iteration Count Detection
 * @description Detects key derivation functions using inadequate iteration counts.
 * 
 * When deriving cryptographic keys from user inputs (e.g., passwords), it's critical
 * to use a sufficiently high iteration count (minimum 10,000) to protect against
 * brute force attacks.
 * 
 * This query identifies two security concerns:
 * 1. Iteration counts explicitly configured below the security threshold
 * 2. Iteration count sources that cannot be statically analyzed
 * 
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

// Select key derivation operations with potentially insufficient iteration counts
from KeyDerivationOperation keyDerivationOp, string warningMessage, DataFlow::Node iterationCountSource
where
  // Filter for operations that require iteration configuration
  keyDerivationOp.requiresIteration() and
  // Identify the source node for iteration count configuration
  iterationCountSource = keyDerivationOp.getIterationSizeSrc() and
  (
    // Check for explicitly defined iteration counts below security threshold
    exists(int iterationValue |
      iterationValue = iterationCountSource.asExpr().(IntegerLiteral).getValue() and
      iterationValue < 10000 and
      warningMessage = "Insufficient iteration count detected. "
    )
    or
    // Check for iteration counts that cannot be statically determined
    not exists(iterationCountSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Iteration count cannot be statically verified. "
  )
select 
  // Report the key derivation operation with appropriate security warning
  keyDerivationOp, warningMessage + "Minimum required iteration count is 10000. Configuration source: $@",
  iterationCountSource.asExpr(), iterationCountSource.asExpr().toString()