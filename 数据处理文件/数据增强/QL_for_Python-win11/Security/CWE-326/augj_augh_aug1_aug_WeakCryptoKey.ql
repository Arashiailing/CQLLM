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

from Cryptography::PublicKey::KeyGeneration cryptoKeyGen, int keyBitLen, DataFlow::Node keySizeSrcNode
where
  // Extract cryptographic key bit length from generation context
  keyBitLen = cryptoKeyGen.getKeySizeWithOrigin(keySizeSrcNode)
  and
  // Verify key length against minimum security threshold
  keyBitLen < cryptoKeyGen.minimumSecureKeySize()
  and
  // Exclude test code from security analysis scope
  not keySizeSrcNode.getScope().getScope*() instanceof TestScope
select cryptoKeyGen,
  "Creation of $@ key uses " + keyBitLen.toString() + " bits, which is below " +
    cryptoKeyGen.minimumSecureKeySize() + " and considered breakable.", 
  keySizeSrcNode, cryptoKeyGen.getName()