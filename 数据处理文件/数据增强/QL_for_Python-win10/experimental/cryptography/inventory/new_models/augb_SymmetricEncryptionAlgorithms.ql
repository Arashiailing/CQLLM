/**
 * @name Symmetric Encryption Algorithms Detection
 * @description Identifies all instances of symmetric encryption algorithm usage across supported cryptographic libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Define variable for symmetric encryption algorithm instances
from SymmetricEncryptionAlgorithm symmetricEncryptionAlgorithm

// Construct result message with algorithm name
select symmetricEncryptionAlgorithm, 
       "Use of algorithm " + symmetricEncryptionAlgorithm.getEncryptionName()