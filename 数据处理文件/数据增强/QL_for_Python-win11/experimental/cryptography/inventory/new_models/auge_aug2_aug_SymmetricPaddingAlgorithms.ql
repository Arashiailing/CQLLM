/**
 * @name Symmetric Encryption Padding Detection
 * @description Detects symmetric encryption algorithms employing padding schemes,
 *              which may introduce vulnerabilities to cryptographic attacks
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding paddingScheme
select paddingScheme, "Algorithm using padding scheme: " + paddingScheme.getPaddingName()