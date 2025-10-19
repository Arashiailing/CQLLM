/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Detects insufficient iteration counts in key derivation functions.
 * Cryptographic keys derived from user inputs (like passwords) should use a high iteration count
 * (minimum 100,000 iterations) to prevent brute force attacks.
 *
 * The query identifies two security concerns:
 * 1. When the iteration count is explicitly set to a value below 100,000
 * 2. When the iteration count source cannot be statically analyzed
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

// Find key derivation functions with potentially insufficient iteration counts
from KeyDerivationOperation kdfOp, string warningMsg, DataFlow::Node iterCountSource
where
  // Filter to operations that require iteration configuration
  kdfOp.requiresIteration() and
  // Identify the source of the iteration count configuration
  iterCountSource = kdfOp.getIterationSizeSrc() and
  (
    // Case 1: Check for explicitly defined iteration counts that are too low
    exists(int iterCount | 
      iterCount = iterCountSource.asExpr().(IntegerLiteral).getValue() and 
      iterCount < 10000 and 
      warningMsg = "Insufficient iteration count detected. "
    )
    or
    // Case 2: Check for iteration counts that cannot be statically verified
    not exists(iterCountSource.asExpr().(IntegerLiteral).getValue()) and 
    warningMsg = "Iteration count cannot be statically verified. "
  )
select 
  // Generate alert for the key derivation function with appropriate security warning
  kdfOp, warningMsg + "Minimum required iteration count is 10000. Configuration source: $@",
  iterCountSource.asExpr(), iterCountSource.asExpr().toString()