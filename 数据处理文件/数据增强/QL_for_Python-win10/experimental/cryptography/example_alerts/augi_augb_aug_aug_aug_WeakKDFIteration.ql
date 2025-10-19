/**
 * @name Insufficient KDF iteration count vulnerability
 * @description Identifies key derivation functions using iteration counts below recommended threshold
 * 
 * This security query detects cryptographic key derivation operations that utilize iteration counts
 * below the industry-recommended minimum of 10000 iterations. Such configurations are susceptible
 * to brute force and dictionary attacks. Additionally, it flags scenarios where the iteration
 * count cannot be statically determined at analysis time.
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

// Main query: Detect vulnerable key derivation function configurations
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node iterationParamSource
where
  // Filter for KDF operations that require iteration parameters
  kdfOperation.requiresIteration() and
  
  // Identify the source node providing iteration count configuration
  iterationParamSource = kdfOperation.getIterationSizeSrc() and
  
  // Evaluate iteration count configuration for security vulnerabilities
  (
    // Vulnerability case 1: Explicit integer literal with insufficient value
    exists(iterationParamSource.asExpr().(IntegerLiteral).getValue()) and
    iterationParamSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    alertMessage = "Insufficient iteration count detected. "
    
    // Vulnerability case 2: Non-statically determinable iteration count
    or
    not exists(iterationParamSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Iteration count cannot be statically verified. "
  )
select 
  // Output format: vulnerable operation, security alert with iteration config reference, and the configuration expression
  kdfOperation, alertMessage + "Minimum recommended iteration count is 10000. Configuration source: $@",
  iterationParamSource.asExpr(), iterationParamSource.asExpr().toString()