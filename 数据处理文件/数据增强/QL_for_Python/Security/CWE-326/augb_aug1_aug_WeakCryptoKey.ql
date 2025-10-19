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

from Cryptography::PublicKey::KeyGeneration keyGeneration, int keyBitLength, DataFlow::Node keySizeSource
where
  // Extract cryptographic key length from generation context and source node
  keyBitLength = keyGeneration.getKeySizeWithOrigin(keySizeSource)
  and
  // Verify key length meets minimum security requirements
  keyBitLength < keyGeneration.minimumSecureKeySize()
  and
  // Exclude test code from security analysis scope
  not keySizeSource.getScope().getScope*() instanceof TestScope
select keyGeneration,
  "Creation of $@ key uses " + keyBitLength.toString() + " bits, which is below " +
    keyGeneration.minimumSecureKeySize() + " and considered breakable.", 
  keySizeSource, keyGeneration.getName()