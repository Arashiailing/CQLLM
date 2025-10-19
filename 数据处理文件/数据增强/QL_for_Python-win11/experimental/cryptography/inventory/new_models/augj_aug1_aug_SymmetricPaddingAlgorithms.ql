/**
 * @name Symmetric Encryption Padding Schemes Detection
 * @description Detects symmetric encryption algorithms that employ padding schemes,
 *              which could be susceptible to specific cryptographic attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding symmetricEncWithPadding
select symmetricEncWithPadding, "Identified symmetric encryption with padding: " + symmetricEncWithPadding.getPaddingName()