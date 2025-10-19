/**
 * @name Cryptographic Hash Algorithm Detection
 * @description Identifies all cryptographic hash algorithm usages across supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from HashAlgorithm cryptoHash

select cryptoHash, "Use of algorithm " + cryptoHash.getName()