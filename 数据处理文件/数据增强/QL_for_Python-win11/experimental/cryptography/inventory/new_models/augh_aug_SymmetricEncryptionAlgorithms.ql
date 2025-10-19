/**
 * @name Symmetric Encryption Algorithms Detection
 * @description Identifies all occurrences of symmetric encryption algorithms
 *              being utilized in the Python codebase through supported
 *              cryptographic libraries. This helps assess cryptographic
 *              posture for quantum readiness.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm symmetricAlgoUsage
select symmetricAlgoUsage, 
       "Use of algorithm " + symmetricAlgoUsage.getEncryptionName()