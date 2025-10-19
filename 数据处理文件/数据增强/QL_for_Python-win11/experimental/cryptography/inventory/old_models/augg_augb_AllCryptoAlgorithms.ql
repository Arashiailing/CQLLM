/**
 * @name Comprehensive Cryptographic Algorithm Detection
 * @description Discovers all instances of cryptographic algorithm utilization 
 *              across supported libraries, capturing both algorithm identifiers 
 *              and block cipher operational modes.
 * @kind problem
 * @id py/quantum-readiness/cbom/classic-model/all-cryptographic-algorithms
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import semmle.python.Concepts

from Cryptography::CryptographicOperation cryptographicOperation, string algorithmIdentifier
where 
  // Capture either the algorithm name or block cipher mode from the cryptographic operation
  algorithmIdentifier = cryptographicOperation.getAlgorithm().getName() 
  or 
  algorithmIdentifier = cryptographicOperation.getBlockMode()
select cryptographicOperation, "Use of algorithm " + algorithmIdentifier