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

// Select key derivation operations with insufficient iteration counts
from KeyDerivationOperation kdfOp, string alertMsg, DataFlow::Node iterSrc
where
  // Focus on operations requiring iteration configuration
  kdfOp.requiresIteration() and
  // Identify the source of iteration count configuration
  iterSrc = kdfOp.getIterationSizeSrc() and
  // Evaluate iteration count source for security compliance
  (
    // Case 1: Explicitly defined iteration count below threshold
    exists(IntegerLiteral lit |
      lit = iterSrc.asExpr() and
      lit.getValue() < 100000 and
      alertMsg = "Insufficient iteration count detected. "
    )
    or
    // Case 2: Iteration count cannot be statically verified
    not iterSrc.asExpr() instanceof IntegerLiteral and
    alertMsg = "Iteration count cannot be statically verified. "
  )
select 
  // Report the key derivation operation with appropriate warning message
  kdfOp, 
  alertMsg + "Minimum required iteration count is 100000. " + 
  "Configuration source: $@",
  iterSrc.asExpr(), 
  iterSrc.asExpr().toString()