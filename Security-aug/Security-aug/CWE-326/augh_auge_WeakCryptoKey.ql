/**
 * @name Use of weak cryptographic key
 * @description Identifies cryptographic key generation with insufficient key length
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

// Detect cryptographic key generators with insufficient key sizes
from Cryptography::PublicKey::KeyGeneration keyGenerator, 
     int keySize, 
     DataFlow::Node keySizeOrigin
where 
  // Extract key size and trace its origin
  keySize = keyGenerator.getKeySizeWithOrigin(keySizeOrigin) 
  and 
  // Verify key size meets security requirements
  keySize < keyGenerator.minimumSecureKeySize() 
  and 
  // Exclude test code from analysis scope
  not keySizeOrigin.getScope().getScope*() instanceof TestScope
select keyGenerator,
  "Creation of an " + keyGenerator.getName() + " key uses $@ bits, which is below " +
    keyGenerator.minimumSecureKeySize() + " and considered breakable.", 
  keySizeOrigin, keySize.toString()