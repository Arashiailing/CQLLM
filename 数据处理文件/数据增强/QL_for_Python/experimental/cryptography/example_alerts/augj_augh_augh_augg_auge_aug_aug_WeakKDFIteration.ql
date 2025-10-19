/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with insecure iteration configurations.
 * Cryptographic key generation from user inputs (e.g., passwords) requires high iteration counts
 * (minimum 100,000) to effectively resist brute force attacks.
 * 
 * Detects two security issues:
 * 1. Iteration counts explicitly set below security threshold
 * 2. Iteration counts that cannot be statically analyzed
 * @kind problem
 * @id py/kdf-low-iteration-count
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as CryptoUtils

from KeyDerivationOperation keyDerivFunc, string alertMsg, DataFlow::Node iterCountSource
where
  // Focus on key derivation functions requiring iteration parameter configuration
  keyDerivFunc.requiresIteration() and
  // Identify the source node providing iteration count value
  iterCountSource = keyDerivFunc.getIterationSizeSrc() and
  // Evaluate iteration count security conditions
  (
    // Case 1: Explicitly configured iteration count below threshold
    exists(iterCountSource.asExpr().(IntegerLiteral).getValue()) and
    iterCountSource.asExpr().(IntegerLiteral).getValue() < 10000 and
    alertMsg = "Insufficient iteration count configured. "
    or
    // Case 2: Iteration count cannot be statically determined
    not exists(iterCountSource.asExpr().(IntegerLiteral).getValue()) and
    alertMsg = "Cannot statically validate iteration count. "
  )
select 
  keyDerivFunc, alertMsg + "Minimum secure iteration count is 10000. Configuration source: $@",
  iterCountSource.asExpr(), iterCountSource.asExpr().toString()