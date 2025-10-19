/**
 * @name Weak cryptographic key usage
 * @description Identifies cryptographic keys generated with insufficient bit length,
 *              rendering them susceptible to brute-force attacks.
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

from Cryptography::PublicKey::KeyGeneration weakKeyGeneration, int keyBitLength, DataFlow::Node keyLengthSource
where
  // Extract key bit length and trace its source in the code
  keyBitLength = weakKeyGeneration.getKeySizeWithOrigin(keyLengthSource)
  and
  // Determine if the key length falls below the secure threshold
  keyBitLength < weakKeyGeneration.minimumSecureKeySize()
  and
  // Exclude test code to focus on production vulnerabilities
  not keyLengthSource.getScope().getScope*() instanceof TestScope
select weakKeyGeneration,
  "Creation of $@ key uses " + keyBitLength.toString() + " bits, which is below " +
    weakKeyGeneration.minimumSecureKeySize() + " and considered breakable.", 
  keyLengthSource, weakKeyGeneration.getName()