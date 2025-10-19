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
from KeyDerivationOperation keyDerivationFunction, string securityWarning, DataFlow::Node iterationSource
where
  // Filter to operations that require iteration configuration
  keyDerivationFunction.requiresIteration() and
  // Identify the source of the iteration count configuration
  iterationSource = keyDerivationFunction.getIterationSizeSrc() and
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
  // Generate alert for the key derivation function with appropriate security warning
  keyDerivationFunction, securityWarning + "Minimum required iteration count is 10000. Configuration source: $@",
  iterationSource.asExpr(), iterationSource.asExpr().toString()