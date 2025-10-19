/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Detects insufficient iteration counts in key derivation functions.
 * Cryptographic keys derived from user inputs (like passwords) should use a high iteration count
 * (minimum 100,000 iterations) to prevent brute force attacks.
 *
 * The query flags two potential issues:
 * 1. When the iteration count is a constant value less than 100,000
 * 2. When the iteration count source cannot be statically determined
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

// Define main query components
from KeyDerivationOperation keyDerivOp, string warningMsg, DataFlow::Node iterCountSrc
where
  // Ensure operation requires iteration configuration
  keyDerivOp.requiresIteration() and
  // Identify iteration count configuration source
  iterCountSrc = keyDerivOp.getIterationSizeSrc() and
  // Evaluate iteration count conditions
  (
    // Case 1: Explicitly defined iteration count is too low
    exists(IntegerLiteral lit |
      lit = iterCountSrc.asExpr() and
      lit.getValue() < 10000 and
      warningMsg = "Insufficient iteration count detected. "
    )
    or
    // Case 2: Iteration count cannot be statically verified
    not exists(iterCountSrc.asExpr()) and
    warningMsg = "Iteration count cannot be statically verified. "
  )
select 
  // Report key derivation operation with warning message
  keyDerivOp, warningMsg + "Minimum required iteration count is 10000. Configuration source: $@",
  iterCountSrc.asExpr(), iterCountSrc.asExpr().toString()