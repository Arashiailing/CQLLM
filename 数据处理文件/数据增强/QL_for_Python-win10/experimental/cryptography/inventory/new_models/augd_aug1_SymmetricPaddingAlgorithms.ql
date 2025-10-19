/**
 * @name Symmetric Encryption Padding Schemes Detection
 * @description Detects and reports cryptographic padding schemes that are utilized in conjunction with symmetric encryption algorithms.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding symmetricPadding
select symmetricPadding, 
       "Use of algorithm " + symmetricPadding.getPaddingName()