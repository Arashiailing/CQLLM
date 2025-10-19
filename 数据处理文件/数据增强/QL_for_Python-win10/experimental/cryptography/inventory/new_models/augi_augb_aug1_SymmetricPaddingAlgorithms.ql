/**
 * @name Detection of Symmetric Encryption Padding Schemes
 * @description Identifies padding mechanisms applied in symmetric encryption algorithms.
 *              This analysis highlights specific padding implementations that may influence
 *              security posture, particularly in quantum readiness evaluations and CBOM analysis.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding paddingMethod
select paddingMethod,
       "Use of algorithm " + paddingMethod.getPaddingName()