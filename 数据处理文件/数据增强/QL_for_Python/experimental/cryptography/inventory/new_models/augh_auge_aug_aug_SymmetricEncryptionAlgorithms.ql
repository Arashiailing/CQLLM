/**
 * @name Symmetric Encryption Algorithm Detection
 * @description Identifies usage of symmetric encryption algorithms in Python codebases,
 *              specifically targeting recognized cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm symmetricAlgo
select symmetricAlgo, 
       "Use of algorithm " + symmetricAlgo.getEncryptionName()