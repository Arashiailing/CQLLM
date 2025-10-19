/**
 * @name Insufficient KDF iteration count vulnerability
 * @description Detects key derivation functions with iteration counts below 100k
 * 
 * This query identifies KDF operations that use iteration counts below the recommended
 * minimum of 10000 iterations, making them vulnerable to brute force attacks.
 * It also flags cases where the iteration count cannot be statically determined.
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
from KeyDerivationOperation keyDerivationOp, string warningMessage, DataFlow::Node iterationCountSource
where
  // Step 1: Filter for KDF operations that require iteration parameters
  keyDerivationOp.requiresIteration() and
  
  // Step 2: Identify the source of the iteration count configuration
  iterationCountSource = keyDerivationOp.getIterationSizeSrc() and
  
  // Step 3: Check for vulnerable iteration count configurations
  (
    // Case 1: Explicit integer literal with insufficient value
    exists(iterationCountSource.asExpr().(IntegerLiteral).getValue()) and
    iterationCountSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    warningMessage = "Iteration count is too low. "
    
    // Case 2: Non-statically determinable iteration count
    or
    not exists(iterationCountSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Iteration count is not a statically verifiable size. "
  )
select 
  // Output format: operation, warning message with iteration config reference, and the config expression
  keyDerivationOp, warningMessage + "Iteration count must be a minimum of 10000. Iteration Config: $@",
  iterationCountSource.asExpr(), iterationCountSource.asExpr().toString()