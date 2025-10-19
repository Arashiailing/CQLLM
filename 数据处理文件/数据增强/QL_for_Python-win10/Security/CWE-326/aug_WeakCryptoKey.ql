/**
 * @name Weak cryptographic key usage
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

from Cryptography::PublicKey::KeyGeneration keyGenerationInstance, int keyBitLength, DataFlow::Node keySizeSource
where
  // Retrieve key bit length from generation instance and source node
  keyBitLength = keyGenerationInstance.getKeySizeWithOrigin(keySizeSource)
  and
  // Verify key length is below minimum security threshold
  keyBitLength < keyGenerationInstance.minimumSecureKeySize()
  and
  // Exclude test code from analysis scope
  not keySizeSource.getScope().getScope*() instanceof TestScope
select keyGenerationInstance,
  "Creation of $@ key uses " + keyBitLength.toString() + " bits, which is below " +
    keyGenerationInstance.minimumSecureKeySize() + " and considered breakable.", 
  keySizeSource, keyGenerationInstance.getName()