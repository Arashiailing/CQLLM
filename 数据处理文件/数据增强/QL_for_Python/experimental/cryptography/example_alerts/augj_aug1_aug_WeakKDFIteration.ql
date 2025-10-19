/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with insufficient iteration counts.
 * Cryptographic keys derived from user inputs (like passwords) must use a high iteration count
 * (minimum 100,000 iterations) to mitigate brute force attacks.
 *
 * Flags two potential issues:
 * 1. Explicit iteration count below 100,000 threshold
 * 2. Iteration count source that cannot be statically verified
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
from KeyDerivationOperation kdfOperation, string warningMessage, DataFlow::Node iterationSource
where
  // Focus on operations requiring iteration configuration
  kdfOperation.requiresIteration() and
  // Identify the source of iteration count configuration
  iterationSource = kdfOperation.getIterationSizeSrc() and
  (
    // Case 1: Explicitly defined iteration count below threshold
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
  kdfOperation, warningMessage + "Minimum required iteration count is 100000. Configuration source: $@",
  iterationSource.asExpr(), iterationSource.asExpr().toString()