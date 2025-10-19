/**
 * @name Weak cryptographic key usage
 * @description Detects cryptographic keys with insufficient bit length vulnerable to brute-force attacks.
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

from Cryptography::PublicKey::KeyGeneration keyGenNode, int keyBits, DataFlow::Node lenSourceNode
where
  // Retrieve cryptographic key parameters and length source
  keyBits = keyGenNode.getKeySizeWithOrigin(lenSourceNode)
  and
  // Verify key length against security baseline
  keyBits < keyGenNode.minimumSecureKeySize()
  and
  // Filter out test environments from security analysis
  not lenSourceNode.getScope().getScope*() instanceof TestScope
select keyGenNode,
  "Creation of $@ key uses " + keyBits.toString() + " bits, which is below " +
    keyGenNode.minimumSecureKeySize() + " and considered breakable.", 
  lenSourceNode, keyGenNode.getName()