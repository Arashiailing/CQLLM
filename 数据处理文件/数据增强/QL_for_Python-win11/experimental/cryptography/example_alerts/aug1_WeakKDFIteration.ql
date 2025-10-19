/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Detects insufficient iteration counts in key derivation functions.
 * Cryptographic keys derived from user inputs (like passwords) must use sufficient
 * iterations to resist brute-force attacks. This query flags:
 * 1) Explicit iteration counts < 100,000
 * 2) Non-static iteration counts that can't be verified
 * @kind problem
 * @id py/kdf-low-iteration-count
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation kdfOp, string alertMessage, DataFlow::Node iterationSource
where
  kdfOp.requiresIteration() and
  iterationSource = kdfOp.getIterationSizeSrc() and
  (
    // Case 1: Explicitly defined iteration count below threshold
    exists(int iterationValue | 
      iterationValue = iterationSource.asExpr().(IntegerLiteral).getValue() and
      iterationValue < 100000 and
      alertMessage = "Iteration count is too low. "
    )
    or
    // Case 2: Non-static iteration count
    not exists(iterationSource.asExpr().(IntegerLiteral).getValue()) and
    alertMessage = "Iteration count is not a statically verifiable size. "
  )
select 
  kdfOp, 
  alertMessage + "Iteration count must be a minimum of 100000. Iteration Config: $@",
  iterationSource.asExpr(), 
  iterationSource.asExpr().toString()