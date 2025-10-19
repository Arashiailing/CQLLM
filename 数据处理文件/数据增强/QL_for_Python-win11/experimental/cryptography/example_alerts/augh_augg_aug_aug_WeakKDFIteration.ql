/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with insufficient iteration counts.
 * 
 * Cryptographic keys derived from user inputs (like passwords) should use a high iteration count
 * (minimum 100,000 iterations) to make brute force attacks computationally infeasible.
 * 
 * This query detects two potential security issues:
 * 1. Explicitly configured iteration counts below the recommended threshold
 * 2. Iteration counts that cannot be statically verified (potentially unsafe)
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

// Find key derivation functions with potentially insufficient iteration counts
from KeyDerivationOperation keyDerivationFunc, string alertMessage, DataFlow::Node iterationSource
where
  // Filter to operations that require iteration configuration
  keyDerivationFunc.requiresIteration() and
  // Identify the source of the iteration count configuration
  iterationSource = keyDerivationFunc.getIterationSizeSrc() and
  // Check for two potential security issues
  (
    // Security issue 1: Explicitly defined iteration count is too low
    exists(iterationSource.asExpr().(IntegerLiteral).getValue()) and
    iterationSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    alertMessage = "Insufficient iteration count detected. "
    // Security issue 2: Iteration count cannot be statically verified
    or
    not exists(iterationSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Iteration count cannot be statically verified. "
  )
select 
  // Generate alert for the key derivation function with appropriate security warning
  keyDerivationFunc, alertMessage + "Minimum required iteration count is 10000. Configuration source: $@",
  iterationSource.asExpr(), iterationSource.asExpr().toString()