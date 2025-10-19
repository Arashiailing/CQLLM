/**
 * @name Symmetric Encryption Padding Schemes Detection
 * @description Identifies symmetric encryption algorithms that utilize padding schemes,
 *              which may be vulnerable to certain cryptographic attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding symmetricCipherWithPadding
select symmetricCipherWithPadding, 
       "Identified symmetric encryption with padding: " + symmetricCipherWithPadding.getPaddingName()