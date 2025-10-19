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
from KeyDerivationOperation kdfOperation, string warningMessage, DataFlow::Node iterationSourceNode
where
  // Filter for KDF operations that require iteration parameters
  kdfOperation.requiresIteration() and
  // Identify the source of the iteration count configuration
  iterationSourceNode = kdfOperation.getIterationSizeSrc() and
  (
    // Case 1: Explicit integer literal with insufficient value
    exists(iterationSourceNode.asExpr().(IntegerLiteral).getValue()) and
    iterationSourceNode.asExpr().(IntegerLiteral).getValue() < 10000 and
    warningMessage = "Iteration count is too low. "
    or
    // Case 2: Non-statically determinable iteration count
    not exists(iterationSourceNode.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Iteration count is not a statically verifiable size. "
  )
select 
  // Output format: operation, warning message with iteration config reference, and the config expression
  kdfOperation, warningMessage + "Iteration count must be a minimum of 10000. Iteration Config: $@",
  iterationSourceNode.asExpr(), iterationSourceNode.asExpr().toString()