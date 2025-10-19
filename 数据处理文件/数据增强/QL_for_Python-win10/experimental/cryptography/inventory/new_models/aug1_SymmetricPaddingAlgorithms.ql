/**
 * @name Symmetric Padding Schemes
 * @description Identifies cryptographic padding schemes used with symmetric encryption algorithms.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding paddingScheme
select paddingScheme, 
       "Use of algorithm " + paddingScheme.getPaddingName()