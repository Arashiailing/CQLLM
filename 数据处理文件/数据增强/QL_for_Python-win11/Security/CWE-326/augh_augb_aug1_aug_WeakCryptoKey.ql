/**
 * @name Weak cryptographic key usage
 * @description Detects cryptographic keys that are generated with insufficient bit length,
 *              making them vulnerable to brute-force attacks.
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

from Cryptography::PublicKey::KeyGeneration cryptoKeyGen, int keySizeBits, DataFlow::Node keySizeOrigin
where
  // Step 1: Extract the key size from the generation context
  keySizeBits = cryptoKeyGen.getKeySizeWithOrigin(keySizeOrigin)
  and
  // Step 2: Verify the key size is below the secure threshold
  keySizeBits < cryptoKeyGen.minimumSecureKeySize()
  and
  // Step 3: Filter out test code to focus on production code
  not keySizeOrigin.getScope().getScope*() instanceof TestScope
select cryptoKeyGen,
  "Creation of $@ key uses " + keySizeBits.toString() + " bits, which is below " +
    cryptoKeyGen.minimumSecureKeySize() + " and considered breakable.", 
  keySizeOrigin, cryptoKeyGen.getName()