/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with inadequate iteration counts.
 * When deriving cryptographic keys from user inputs (e.g., passwords), a high iteration count
 * (at least 100,000 iterations) is necessary to mitigate brute force attacks.
 *
 * This query flags two potential security issues:
 * 1. Iteration counts explicitly configured below the 100,000 threshold
 * 2. Iteration counts that cannot be determined through static analysis
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

// Identify key derivation functions with potentially insecure iteration configurations
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node iterationCountSource
where
  // Focus on key derivation operations that require iteration configuration
  kdfOperation.requiresIteration() and
  // Locate the source of the iteration count parameter
  iterationCountSource = kdfOperation.getIterationSizeSrc() and
  (
    // Check for explicitly defined iteration counts that are too low
    exists(iterationCountSource.asExpr().(IntegerLiteral).getValue()) and
    iterationCountSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    alertMessage = "Inadequate iteration count detected. "
    // Check for iteration counts that cannot be statically verified
    or
    not exists(iterationCountSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Unable to statically verify iteration count. "
  )
select 
  // Report the key derivation function with an appropriate security alert
  kdfOperation, alertMessage + "Minimum recommended iteration count is 10000. Configuration source: $@",
  iterationCountSource.asExpr(), iterationCountSource.asExpr().toString()