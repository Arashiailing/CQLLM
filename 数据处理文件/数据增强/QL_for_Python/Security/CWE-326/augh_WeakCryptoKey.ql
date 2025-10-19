/**
 * @name Use of weak cryptographic key
 * @description Detects cryptographic keys with insufficient bit length that compromise security
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

// Identify cryptographic key generation operations
from Cryptography::PublicKey::KeyGeneration cryptoKeyGen, 
     int keyLength, 
     DataFlow::Node sourceNode
where
  // Retrieve key length from generation operation and verify security threshold
  keyLength = cryptoKeyGen.getKeySizeWithOrigin(sourceNode) and
  keyLength < cryptoKeyGen.minimumSecureKeySize() and
  // Exclude test code from analysis scope
  not sourceNode.getScope().getScope*() instanceof TestScope
select cryptoKeyGen,
  // Generate alert message with key details and security recommendation
  "Creation of an " + cryptoKeyGen.getName() + " key uses $@ bits, which is below " +
    cryptoKeyGen.minimumSecureKeySize() + " and considered breakable.", 
  sourceNode, 
  keyLength.toString()