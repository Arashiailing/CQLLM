/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with insufficient iteration counts.
 * Keys derived from user inputs (e.g., passwords) must use high iteration counts
 * (minimum 100,000 iterations) to mitigate brute force attacks.
 *
 * This query detects two security concerns:
 * 1. Iteration count is a constant value below the 100,000 threshold
 * 2. Iteration count source cannot be statically determined
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

// Define variables for key derivation operations and related information
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node iterationSource
where
  // Filter operations that require iteration configuration
  kdfOperation.requiresIteration() and
  // Extract the source of iteration count configuration
  iterationSource = kdfOperation.getIterationSizeSrc() and
  (
    // Case 1: Explicit iteration count that is too low
    exists(iterationSource.asExpr().(IntegerLiteral).getValue()) and
    iterationSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    alertMessage = "Insufficient iteration count detected. "
    // Case 2: Iteration count that cannot be statically verified
    or
    not exists(iterationSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Iteration count cannot be statically verified. "
  )
select 
  // Report the key derivation operation with appropriate security alert
  kdfOperation, alertMessage + "Minimum required iteration count is 10000. Configuration source: $@",
  iterationSource.asExpr(), iterationSource.asExpr().toString()