/**
 * @name Cryptographic Hash Algorithms Detection
 * @description Detects all cryptographic hash algorithm implementations 
 *              across Python cryptographic libraries. This identification 
 *              helps locate algorithms requiring quantum-resistant alternatives.
 * @kind problem
 * @id py/quantum-readiness/cbom/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from HashAlgorithm hashAlgoInstance
select hashAlgoInstance, "Use of algorithm " + hashAlgoInstance.getName()