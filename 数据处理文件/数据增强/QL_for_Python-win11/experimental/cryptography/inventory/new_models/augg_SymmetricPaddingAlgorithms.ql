/**
 * @name Symmetric Padding Schemes
 * @description Identifies symmetric encryption algorithms that utilize padding schemes.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Query for symmetric encryption algorithms with padding schemes
from SymmetricPadding paddingScheme
// Select the algorithm and its padding scheme description
select paddingScheme, "Use of algorithm " + paddingScheme.getPaddingName()