/**
 * @name Insufficient KDF Iteration Count Detection
 * @description Identifies key derivation functions with inadequate iteration counts.
 * 
 * Cryptographic keys derived from user-provided inputs (such as passwords) must employ
 * a high iteration count (at least 100,000 iterations) to mitigate brute force attacks.
 * 
 * This query detects two potential security issues:
 * 1. Iteration count explicitly set to a constant value below the recommended threshold
 * 2. Iteration count source that cannot be statically determined during analysis
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

// Select key derivation operations that may have insufficient iteration counts
from KeyDerivationOperation kdfOperation, string securityWarning, DataFlow::Node iterationSource
where
  // Focus on operations that require iteration configuration
  kdfOperation.requiresIteration() and
  // Identify the source of the iteration count configuration
  iterationSource = kdfOperation.getIterationSizeSrc() and
  (
    // Case 1: Check for explicitly defined iteration counts that are too low
    exists(iterationSource.asExpr().(IntegerLiteral).getValue()) and
    iterationSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    securityWarning = "Insufficient iteration count detected. "
    // Case 2: Check for iteration counts that cannot be statically verified
    or
    not exists(iterationSource.asExpr().(IntegerLiteral).getValue()) and
    securityWarning = "Iteration count cannot be statically verified. "
  )
select 
  // Report the key derivation operation with appropriate warning message
  kdfOperation, securityWarning + "Minimum required iteration count is 10000. Configuration source: $@",
  iterationSource.asExpr(), iterationSource.asExpr().toString()