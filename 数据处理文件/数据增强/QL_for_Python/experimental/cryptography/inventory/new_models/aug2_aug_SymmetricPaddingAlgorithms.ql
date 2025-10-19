/**
 * @name Symmetric Encryption Padding Detection
 * @description Identifies symmetric encryption algorithms that use padding schemes,
 *              which may be vulnerable to certain cryptographic attacks
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding symmetricPadding
select symmetricPadding, "Algorithm using padding scheme: " + symmetricPadding.getPaddingName()