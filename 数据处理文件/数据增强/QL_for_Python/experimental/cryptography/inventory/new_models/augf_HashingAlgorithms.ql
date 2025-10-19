/**
 * @name Hash Algorithms Usage
 * @description Identifies all instances where cryptographic hash algorithms are utilized through supported libraries.
 * @kind problem
 * @id py/quantum-readiness/cbom/hash-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from HashAlgorithm hashAlg

select hashAlg, "Use of algorithm " + hashAlg.getName()