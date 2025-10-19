/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with inadequate iteration counts.
 * When deriving cryptographic keys from user-provided inputs (e.g., passwords),
 * a sufficiently high iteration count (at least 100,000) must be used to mitigate
 * brute force attack risks.
 *
 * This query flags two potential security issues:
 * 1. Iteration counts explicitly configured below the recommended threshold
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

// Identify key derivation operations with potentially insecure iteration configurations
from KeyDerivationOperation keyDerivationOp, string securityAlert, DataFlow::Node iterationSource
where
  // Focus on key derivation functions that require iteration parameter configuration
  keyDerivationOp.requiresIteration() and
  // Locate the source node providing the iteration count value
  iterationSource = keyDerivationOp.getIterationSizeSrc() and
  (
    // Scenario 1: Detect explicitly set iteration counts below security threshold
    exists(iterationSource.asExpr().(IntegerLiteral).getValue()) and
    iterationSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    securityAlert = "Inadequate iteration count detected. "
    // Scenario 2: Flag iteration counts that cannot be statically validated
    or
    not exists(iterationSource.asExpr().(IntegerLiteral).getValue()) and
    securityAlert = "Unable to statically verify iteration count. "
  )
select 
  // Report the key derivation operation with appropriate security alert
  keyDerivationOp, securityAlert + "Minimum secure iteration count is 10000. Configuration source: $@",
  iterationSource.asExpr(), iterationSource.asExpr().toString()