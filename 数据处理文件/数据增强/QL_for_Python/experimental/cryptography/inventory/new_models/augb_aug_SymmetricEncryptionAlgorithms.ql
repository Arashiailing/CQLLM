/**
 * @name Symmetric Encryption Algorithms Detection
 * @description Detects usage of symmetric encryption algorithms in Python code
 *              through supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm symmetricAlgo
select symmetricAlgo, "Use of algorithm " + symmetricAlgo.getEncryptionName()