/**
 * @name Weak cryptographic key usage
 * @description Identifies cryptographic keys with insufficient bit length that are vulnerable to brute-force attacks.
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

from Cryptography::PublicKey::KeyGeneration keyGeneratorNode, int keySizeInBits, DataFlow::Node keySizeSourceNode
where
  // Extract cryptographic key parameters and identify the source of key length specification
  keySizeInBits = keyGeneratorNode.getKeySizeWithOrigin(keySizeSourceNode)
  and
  // Validate key length against established security thresholds
  keySizeInBits < keyGeneratorNode.minimumSecureKeySize()
  and
  // Exclude test environments from security analysis scope
  not keySizeSourceNode.getScope().getScope*() instanceof TestScope
select keyGeneratorNode,
  "Creation of $@ key uses " + keySizeInBits.toString() + " bits, which is below " +
    keyGeneratorNode.minimumSecureKeySize() + " and considered breakable.", 
  keySizeSourceNode, keyGeneratorNode.getName()