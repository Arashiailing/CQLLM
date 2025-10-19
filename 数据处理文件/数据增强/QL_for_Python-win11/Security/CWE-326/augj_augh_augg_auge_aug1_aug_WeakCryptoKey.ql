/**
 * @name Insufficient cryptographic key strength
 * @description Identifies cryptographic keys with bit lengths below security thresholds, susceptible to brute-force attacks
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

from Cryptography::PublicKey::KeyGeneration keyGen, int keyBitLength, DataFlow::Node keySizeOrigin
where
  // Trace key size parameter to its source
  keyBitLength = keyGen.getKeySizeWithOrigin(keySizeOrigin)
  and
  // Validate against minimum security requirements
  keyBitLength < keyGen.minimumSecureKeySize()
  and
  // Exclude test code from analysis scope
  not keySizeOrigin.getScope().getScope*() instanceof TestScope
select keyGen,
  "Generation of $@ key uses " + keyBitLength.toString() + " bits, below the secure threshold of " +
    keyGen.minimumSecureKeySize().toString() + " bits (vulnerable to brute-force attacks).", 
  keySizeOrigin, keyGen.getName()