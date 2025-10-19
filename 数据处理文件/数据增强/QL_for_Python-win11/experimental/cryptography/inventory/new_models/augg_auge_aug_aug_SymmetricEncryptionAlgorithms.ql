/**
 * @name Detection of Symmetric Encryption Algorithms
 * @description Locates symmetric encryption algorithm implementations in Python projects,
 *              with emphasis on established cryptographic libraries.
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
       "Algorithm usage detected: " + symmetricAlgo.getEncryptionName()