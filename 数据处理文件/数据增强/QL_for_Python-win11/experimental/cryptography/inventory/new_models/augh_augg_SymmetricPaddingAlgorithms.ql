/**
 * @name Symmetric Padding Schemes
 * @description Identifies symmetric encryption algorithms utilizing padding schemes,
 *              which may impact cryptographic security and quantum resistance.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify symmetric encryption algorithms that employ padding mechanisms
from SymmetricPadding scheme
// Report algorithm with its padding scheme description
select scheme, "Use of algorithm " + scheme.getPaddingName()