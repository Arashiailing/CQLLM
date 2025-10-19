/**
 * @name Symmetric Encryption Algorithms Detection
 * @description Identifies usage of symmetric encryption algorithms in cryptographic operations.
 *              This query scans codebases for implementations that utilize symmetric encryption,
 *              which may be vulnerable to quantum computing attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Retrieve all symmetric encryption algorithm instances from the codebase
from SymmetricEncryptionAlgorithm symmetricAlgo

// Generate result message indicating the detected algorithm
select symmetricAlgo, 
       "Use of algorithm " + symmetricAlgo.getEncryptionName()