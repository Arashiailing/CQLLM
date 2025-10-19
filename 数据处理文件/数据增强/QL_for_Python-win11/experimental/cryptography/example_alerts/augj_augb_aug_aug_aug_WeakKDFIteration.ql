/**
 * @name Insufficient KDF iteration count vulnerability
 * @description Identifies key derivation functions using iteration counts below the secure threshold
 * 
 * This security query detects cryptographic key derivation operations that utilize iteration
 * counts below the recommended minimum of 10,000 iterations. Such configurations are
 * susceptible to brute-force attacks. Additionally, the query flags scenarios where
 * the iteration count cannot be statically determined during analysis.
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

// Query body: Detect vulnerable key derivation function configurations
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node iterationParamSource
where
  // Filter for KDF operations that require iteration parameters
  kdfOperation.requiresIteration() and
  
  // Identify the source of iteration count configuration
  iterationParamSource = kdfOperation.getIterationSizeSrc() and
  
  // Evaluate iteration count security
  (
    // Vulnerability case: Explicit integer literal with insufficient value
    exists(iterationParamSource.asExpr().(IntegerLiteral).getValue()) and
    iterationParamSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    alertMessage = "Insufficient iteration count detected. "
    
    // Vulnerability case: Non-statically determinable iteration count
    or
    not exists(iterationParamSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Iteration count cannot be statically verified. "
  )
select 
  // Output format: KDF operation, security alert with configuration reference, and the parameter expression
  kdfOperation, alertMessage + "Minimum 10,000 iterations required for security. Configuration: $@",
  iterationParamSource.asExpr(), iterationParamSource.asExpr().toString()