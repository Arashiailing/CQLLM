/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with insufficient iteration counts.
 * 
 * Detects KDF operations using iteration counts below 10000 or when the iteration count
 * cannot be statically determined from the code.
 * @kind problem
 * @id py/kdf-low-iteration-count
 * @problem.severity error
 * @precision high
 */

// Import standard Python analysis framework
import python
// Import cryptographic concepts for key derivation analysis
import experimental.cryptography.Concepts
// Import utility functions for cryptographic analysis
private import experimental.cryptography.utils.Utils as CryptoUtils

// Query body: Identify vulnerable key derivation operations
from KeyDerivationOperation kdfOp, string alertMsg, DataFlow::Node iterationParamSource
where
  // Filter for KDF operations that require iteration parameters
  kdfOp.requiresIteration() and
  // Identify the source of the iteration count configuration
  iterationParamSource = kdfOp.getIterationSizeSrc() and
  (
    // Case 1: Explicit integer literal with insufficient value
    exists(iterationParamSource.asExpr().(IntegerLiteral).getValue()) and
    iterationParamSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    alertMsg = "Iteration count is too low. "
    // Case 2: Non-statically determinable iteration count
    or
    not exists(iterationParamSource.asExpr().(IntegerLiteral).getValue()) and
    alertMsg = "Iteration count is not a statically verifiable size. "
  )
select 
  // Output format: operation, warning message with iteration config reference, and the config expression
  kdfOp, alertMsg + "Iteration count must be a minimum of 10000. Iteration Config: $@",
  iterationParamSource.asExpr(), iterationParamSource.asExpr().toString()