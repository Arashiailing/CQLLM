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

// Define security threshold for iteration count
int getMinIterationCount() { result = 100000 }

// Select key derivation operations with insufficient iteration counts
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node iterationCountSource
where
  // Focus only on operations that require iteration configuration
  kdfOperation.requiresIteration() and
  // Identify the source node that configures the iteration count
  iterationCountSource = kdfOperation.getIterationSizeSrc() and
  // Evaluate iteration count against security requirements
  (
    // Case 1: Iteration count is a constant below the security threshold
    exists(IntegerLiteral lit |
      lit = iterationCountSource.asExpr() and
      lit.getValue() < getMinIterationCount() and
      alertMessage = "Insufficient iteration count detected. "
    )
    or
    // Case 2: Iteration count cannot be statically verified
    not iterationCountSource.asExpr() instanceof IntegerLiteral and
    alertMessage = "Iteration count cannot be statically verified. "
  )
select 
  // Report the key derivation operation with appropriate warning message
  kdfOperation, alertMessage + "Minimum required iteration count is 100000. Configuration source: $@",
  iterationCountSource.asExpr(), iterationCountSource.asExpr().toString()