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

// Identify key derivation functions with potentially insecure iteration configurations
from KeyDerivationOperation keyDerivationFunction, string securityWarning, DataFlow::Node iterationCountSource
where
  // Focus on key derivation functions that require iteration parameter configuration
  keyDerivationFunction.requiresIteration() and
  // Locate the source node providing the iteration count value
  iterationCountSource = keyDerivationFunction.getIterationSizeSrc() and
  // Check for two security scenarios: low iteration count or undetermined iteration count
  (
    // Scenario 1: Detect explicitly set iteration counts below security threshold
    exists(iterationCountSource.asExpr().(IntegerLiteral).getValue()) and
    iterationCountSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    securityWarning = "Inadequate iteration count detected. "
    // Scenario 2: Flag iteration counts that cannot be statically validated
    or
    not exists(iterationCountSource.asExpr().(IntegerLiteral).getValue()) and
    securityWarning = "Unable to statically verify iteration count. "
  )
select 
  // Report the key derivation function with appropriate security warning
  keyDerivationFunction, securityWarning + "Minimum secure iteration count is 10000. Configuration source: $@",
  iterationCountSource.asExpr(), iterationCountSource.asExpr().toString()