/**
 * @name Weak cryptographic key usage
 * @description Detects cryptographic keys with insufficient bit length vulnerable to brute-force attacks
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

from Cryptography::PublicKey::KeyGeneration keyGenNode, int keySizeBits, DataFlow::Node keySizeSrcNode
where
  // Extract key size parameters and trace their origin
  keySizeBits = keyGenNode.getKeySizeWithOrigin(keySizeSrcNode)
  and
  // Validate against security thresholds
  keySizeBits < keyGenNode.minimumSecureKeySize()
  and
  // Exclude test code from analysis scope
  not keySizeSrcNode.getScope().getScope*() instanceof TestScope
select keyGenNode,
  "Creation of $@ key uses " + keySizeBits.toString() + " bits, which is below " +
    keyGenNode.minimumSecureKeySize().toString() + " and considered breakable.", 
  keySizeSrcNode, keyGenNode.getName()