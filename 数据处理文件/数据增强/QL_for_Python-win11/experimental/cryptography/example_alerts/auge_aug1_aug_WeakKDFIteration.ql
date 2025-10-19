/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with insufficient iteration counts.
 * When deriving cryptographic keys from user inputs (such as passwords), it's critical to use
 * a high iteration count (at least 100,000 iterations) to effectively resist brute force attacks.
 *
 * This query detects two potential security issues:
 * 1. Constant iteration count values below the recommended threshold of 100,000
 * 2. Iteration counts that cannot be statically determined at analysis time
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
  // Focus only on operations that require iteration configuration
  keyDerivationOp.requiresIteration() and
  // Identify the source node that configures the iteration count
  iterationSource = keyDerivationOp.getIterationSizeSrc() and
  (
    // Case 1: Iteration count is a constant below the security threshold
    iterationSource.asExpr() instanceof IntegerLiteral and
    iterationSource.asExpr().(IntegerLiteral).getValue() < 100000 and
    warningMessage = "Insufficient iteration count detected. "
    or
    // Case 2: Iteration count cannot be statically verified
    not iterationSource.asExpr() instanceof IntegerLiteral and
    warningMessage = "Iteration count cannot be statically verified. "
  )
select 
  // Report the key derivation operation with appropriate warning message
  keyDerivationOp, warningMessage + "Minimum required iteration count is 100000. Configuration source: $@",
  iterationSource.asExpr(), iterationSource.asExpr().toString()