/**
 * @name Symmetric Encryption Algorithms Detection
 * @description Identifies all occurrences of symmetric encryption algorithm usage 
 *              within Python codebases through supported cryptographic libraries.
 *              This detection helps assess quantum readiness by flagging potentially
 *              vulnerable cryptographic implementations.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm symmetricAlgorithm
select symmetricAlgorithm, 
       "Use of algorithm " + symmetricAlgorithm.getEncryptionName()