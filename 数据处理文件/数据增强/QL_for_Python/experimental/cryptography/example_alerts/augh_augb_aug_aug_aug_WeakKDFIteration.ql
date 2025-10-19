/**
 * @name Insufficient KDF iteration count vulnerability
 * @description Identifies key derivation functions using iteration counts below 100k threshold
 * 
 * This security query detects cryptographic key derivation operations that utilize iteration
 * counts below the recommended security threshold of 10000 iterations. Such configurations
 * are susceptible to brute force attacks. Additionally, the query flags scenarios where
 * the iteration count cannot be statically analyzed at compile time.
 * @kind problem
 * @id py/kdf-low-iteration-count
 * @problem.severity error
 * @precision high
 */

// Import core Python analysis capabilities
import python
// Import cryptographic primitives and concepts for key derivation analysis
import experimental.cryptography.Concepts
// Import cryptographic utility functions and helpers
private import experimental.cryptography.utils.Utils as CryptoUtils

// Main query logic: Detect vulnerable key derivation function configurations
from KeyDerivationOperation kdfOperation, string alertMessage, DataFlow::Node iterationParamSource
where
  // Filter for KDF operations that require iteration parameters
  kdfOperation.requiresIteration() and
  
  // Extract the source node providing the iteration count configuration
  iterationParamSource = kdfOperation.getIterationSizeSrc() and
  
  // Analyze iteration count configuration for security vulnerabilities
  (
    // Vulnerability scenario 1: Explicit integer literal with insufficient value
    exists(iterationParamSource.asExpr().(IntegerLiteral).getValue()) and
    iterationParamSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    alertMessage = "Insufficient iteration count detected. "
    
    // Vulnerability scenario 2: Non-statically determinable iteration count
    or
    not exists(iterationParamSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Iteration count cannot be statically verified. "
  )
select 
  // Report format: vulnerable operation, detailed warning with configuration reference, and the configuration expression
  kdfOperation, alertMessage + "Minimum required iterations: 10000. Configuration source: $@",
  iterationParamSource.asExpr(), iterationParamSource.asExpr().toString()