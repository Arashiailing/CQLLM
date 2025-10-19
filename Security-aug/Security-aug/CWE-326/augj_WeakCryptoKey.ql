/**
 * @name Use of weak cryptographic key
 * @description Detects cryptographic keys with insufficient bit length that may be vulnerable to brute-force attacks.
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

// Identify cryptographic key generation operations with insufficient key size
from Cryptography::PublicKey::KeyGeneration keyGeneration, int keyBitSize, DataFlow::Node originNode
where
  // Exclude test code from analysis
  not originNode.getScope().getScope*() instanceof TestScope and
  // Retrieve actual key size from generation operation
  keyBitSize = keyGeneration.getKeySizeWithOrigin(originNode) and
  // Verify key size is below minimum security threshold
  keyBitSize < keyGeneration.minimumSecureKeySize()
select keyGeneration,
  // Generate alert message with key details
  "Creation of an " + keyGeneration.getName() + " key uses $@ bits, which is below " +
    keyGeneration.minimumSecureKeySize() + " and considered breakable.", originNode, keyBitSize.toString()