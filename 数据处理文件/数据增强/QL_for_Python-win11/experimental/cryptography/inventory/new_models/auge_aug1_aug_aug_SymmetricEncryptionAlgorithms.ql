/**
 * @name Symmetric Encryption Algorithm Identification
 * @description Identifies symmetric encryption algorithm implementations across Python codebases
 *              by analyzing supported cryptographic libraries and their usage patterns.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-encryption-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricEncryptionAlgorithm identifiedAlgorithm
select 
    identifiedAlgorithm, 
    "Detected algorithm usage: " + identifiedAlgorithm.getEncryptionName()