/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with inadequate iteration counts.
 * Cryptographic keys derived from user-provided inputs (e.g., passwords) must utilize
 * a substantial iteration count (at least 100,000 iterations) to mitigate brute force attacks.
 *
 * This query detects two problematic scenarios:
 * 1. Constant iteration count values below the 100,000 threshold
 * 2. Iteration count parameters that cannot be statically analyzed
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
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node iterationParam
where
  // Filter for key derivation functions that require iteration configuration
  kdfOperation.requiresIteration() and
  // Extract the node representing the iteration count parameter
  iterationParam = kdfOperation.getIterationSizeSrc() and
  // Define minimum secure iteration threshold
  exists(int minSecureIterations | minSecureIterations = 100000 |
    // Case 1: Explicit constant iteration count below security threshold
    (
      iterationParam.asExpr() instanceof IntegerLiteral and
      iterationParam.asExpr().(IntegerLiteral).getValue() < minSecureIterations and
      alertMessage = "Insecure iteration count detected. "
    )
    or
    // Case 2: Iteration count source cannot be statically determined
    (
      not iterationParam.asExpr() instanceof IntegerLiteral and
      alertMessage = "Unable to verify iteration count statically. "
    )
  )
select 
  // Report the key derivation operation with appropriate security alert
  kdfOperation, 
  alertMessage + "Minimum secure iteration count is " + "100000. " + 
  "Parameter source: $@",
  iterationParam.asExpr(), 
  iterationParam.asExpr().toString()