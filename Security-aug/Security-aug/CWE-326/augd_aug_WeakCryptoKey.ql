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

from Cryptography::PublicKey::KeyGeneration keyGenInstance, int keyLength, DataFlow::Node lengthSource
where
  // Exclude test code from analysis scope
  not lengthSource.getScope().getScope*() instanceof TestScope
  and
  // Retrieve key bit length from generation instance and source node
  keyLength = keyGenInstance.getKeySizeWithOrigin(lengthSource)
  and
  // Verify key length is below minimum security threshold
  keyLength < keyGenInstance.minimumSecureKeySize()
select keyGenInstance,
  "Creation of $@ key uses " + keyLength.toString() + " bits, which is below " +
    keyGenInstance.minimumSecureKeySize() + " and considered breakable.", 
  lengthSource, keyGenInstance.getName()