/**
 * @name Use of weak cryptographic key
 * @description Detects cryptographic key generation with insufficient key length
 * @kind problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/weak-crypto-key
 * @tags security
 *       external/cwe/cwe-326
 */

import python
import semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests

// Identify cryptographic key generators with weak key sizes
from Cryptography::PublicKey::KeyGeneration cryptoKeyGenerator, 
     int generatedKeySize, 
     DataFlow::Node keySizeSource
where 
  // Extract key size from generator and verify its origin
  generatedKeySize = cryptoKeyGenerator.getKeySizeWithOrigin(keySizeSource) and
  // Validate key size against security requirements
  generatedKeySize < cryptoKeyGenerator.minimumSecureKeySize() and
  // Exclude test code from analysis scope
  not keySizeSource.getScope().getScope*() instanceof TestScope
select cryptoKeyGenerator,
  "Creation of an " + cryptoKeyGenerator.getName() + " key uses $@ bits, which is below " +
    cryptoKeyGenerator.minimumSecureKeySize() + " and considered breakable.", 
  keySizeSource, generatedKeySize.toString()