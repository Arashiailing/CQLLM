/**
 * @name Use iteration count at least 100k to prevent brute force attacks
 * @description Identifies key derivation functions with insufficient iteration counts.
 * This query helps prevent brute-force attacks by ensuring that cryptographic keys
 * derived from user inputs (such as passwords) use adequate iterations. The query flags:
 * 1) Explicitly specified iteration counts below 100,000
 * 2) Non-static iteration counts that cannot be statically verified
 * @kind problem
 * @id py/kdf-low-iteration-count
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts
private import experimental.cryptography.utils.Utils as Utils

from KeyDerivationOperation keyDerivationOp, string warningMsg, DataFlow::Node iterationCountSource
where
  keyDerivationOp.requiresIteration() and
  iterationCountSource = keyDerivationOp.getIterationSizeSrc() and
  (
    // Check for explicitly defined iteration count below security threshold
    exists(int iterationCountValue | 
      iterationCountValue = iterationCountSource.asExpr().(IntegerLiteral).getValue() and
      iterationCountValue < 100000 and
      warningMsg = "Insufficient iteration count detected. "
    )
    or
    // Check for non-static iteration count that cannot be verified at analysis time
    not exists(iterationCountSource.asExpr().(IntegerLiteral).getValue()) and
    warningMsg = "Non-static iteration count cannot be verified. "
  )
select 
  keyDerivationOp, 
  warningMsg + "Minimum required iteration count is 100000. Configuration source: $@",
  iterationCountSource.asExpr(), 
  iterationCountSource.asExpr().toString()