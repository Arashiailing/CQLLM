/**
 * @name Symmetric Padding Schemes Detection
 * @description Identifies symmetric encryption algorithms utilizing padding schemes
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding paddingScheme
select paddingScheme, "Detected algorithm with padding: " + paddingScheme.getPaddingName()