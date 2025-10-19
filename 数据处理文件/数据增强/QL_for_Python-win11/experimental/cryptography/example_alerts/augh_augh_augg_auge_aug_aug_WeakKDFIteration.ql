/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Detects key derivation functions configured with insufficient iteration counts.
 * When generating cryptographic keys from user inputs (like passwords), it's critical
 * to use a high iteration count (minimum 100,000) to effectively resist brute force attacks.
 *
 * This query identifies two security concerns:
 * 1. Iteration counts explicitly set below the security threshold
 * 2. Iteration counts that cannot be statically analyzed
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

// Find key derivation functions with potentially insecure iteration configurations
from KeyDerivationOperation kdfOperation, string warningMessage, DataFlow::Node iterationSource
where
  // Filter for key derivation functions that require iteration parameter configuration
  kdfOperation.requiresIteration() and
  // Identify the source node that provides the iteration count value
  iterationSource = kdfOperation.getIterationSizeSrc() and
  // Evaluate security conditions for iteration count
  (
    // Check for explicitly configured iteration counts below security threshold
    exists(iterationSource.asExpr().(IntegerLiteral).getValue()) and
    iterationSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    warningMessage = "Insufficient iteration count configured. "
    // Check for iteration counts that cannot be statically determined
    or
    not exists(iterationSource.asExpr().(IntegerLiteral).getValue()) and
    warningMessage = "Cannot statically validate iteration count. "
  )
select 
  // Report the key derivation function with appropriate security warning
  kdfOperation, warningMessage + "Minimum secure iteration count is 10000. Configuration source: $@",
  iterationSource.asExpr(), iterationSource.asExpr().toString()