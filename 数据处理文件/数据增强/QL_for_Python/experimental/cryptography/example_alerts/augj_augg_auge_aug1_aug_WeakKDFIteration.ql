/**
 * @name Key Derivation: Insufficient Iteration Count Protection
 * @description Detects cryptographic key derivation functions using inadequate iteration counts.
 * When deriving keys from user-provided inputs (e.g., passwords), implementing a high
 * iteration count (minimum 100,000) is essential to mitigate brute-force attacks.
 *
 * Identifies two security concerns:
 * 1. Hardcoded iteration counts below the 100,000 threshold
 * 2. Iteration counts that cannot be statically validated during analysis
 * @kind problem
 * @id py/kdf-low-iteration-count
 * @problem.severity error
 * @precision high
 */

// Import standard Python analysis framework
import python
// Import experimental cryptography concepts for key derivation operations
import experimental.cryptography.Concepts
// Import cryptography analysis utilities with alias
private import experimental.cryptography.utils.Utils as CryptoUtils

// Define security threshold for key derivation iterations
int getMinIterationThreshold() { result = 100000 }

// Analyze key derivation operations for insufficient iteration configurations
from KeyDerivationOperation keyDerivationOp, string warningMsg, DataFlow::Node iterationSource
where
  // Focus on operations requiring iteration configuration
  keyDerivationOp.requiresIteration() and
  // Identify the iteration count configuration source
  iterationSource = keyDerivationOp.getIterationSizeSrc() and
  // Evaluate iteration count security compliance
  (
    // Detect hardcoded iteration counts below security threshold
    exists(IntegerLiteral constValue |
      constValue = iterationSource.asExpr() and
      constValue.getValue() < getMinIterationThreshold() and
      warningMsg = "Insufficient iteration count detected. "
    )
    or
    // Detect non-constant iteration counts that evade static analysis
    not iterationSource.asExpr() instanceof IntegerLiteral and
    warningMsg = "Iteration count cannot be statically verified. "
  )
select 
  // Report vulnerable key derivation operations with contextual warnings
  keyDerivationOp, warningMsg + "Minimum required iteration count is 100000. Configuration source: $@",
  iterationSource.asExpr(), iterationSource.asExpr().toString()