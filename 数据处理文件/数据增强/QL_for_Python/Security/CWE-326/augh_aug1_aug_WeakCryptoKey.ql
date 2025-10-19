/**
 * @name Weak cryptographic key usage
 * @description Identifies cryptographic keys with inadequate bit length that are susceptible to brute-force attacks.
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

from Cryptography::PublicKey::KeyGeneration keyGenInstance, int keyBitLength, DataFlow::Node keySizeSourceNode
where
  // Extract key bit length from generation context and source node
  keyBitLength = keyGenInstance.getKeySizeWithOrigin(keySizeSourceNode)
  and
  // Validate key length against minimum security requirements
  keyBitLength < keyGenInstance.minimumSecureKeySize()
  and
  // Exclude test code from security analysis scope
  not keySizeSourceNode.getScope().getScope*() instanceof TestScope
select keyGenInstance,
  "Creation of $@ key uses " + keyBitLength.toString() + " bits, which is below " +
    keyGenInstance.minimumSecureKeySize() + " and considered breakable.", 
  keySizeSourceNode, keyGenInstance.getName()