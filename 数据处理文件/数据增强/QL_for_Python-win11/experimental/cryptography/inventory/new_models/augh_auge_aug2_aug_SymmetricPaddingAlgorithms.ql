/**
 * @name Symmetric Encryption Padding Detection
 * @description Identifies symmetric encryption algorithms that utilize padding schemes,
 *              which could expose cryptographic vulnerabilities to padding oracle attacks
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding cryptoPadding
select cryptoPadding, "Algorithm using padding scheme: " + cryptoPadding.getPaddingName()