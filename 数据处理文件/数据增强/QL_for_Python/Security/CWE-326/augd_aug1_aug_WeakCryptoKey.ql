/**
 * @name Weak cryptographic key usage
 * @description Detects cryptographic key generation operations that use insufficient key lengths,
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

from Cryptography::PublicKey::KeyGeneration keyGenOperation, int keyBitLength, DataFlow::Node keySizeSource
where
  // Step 1: Extract the actual key bit length from the key generation operation
  keyBitLength = keyGenOperation.getKeySizeWithOrigin(keySizeSource)
  and
  // Step 2: Verify if the key length meets minimum security standards
  keyBitLength < keyGenOperation.minimumSecureKeySize()
  and
  // Step 3: Filter out test code to focus on production code
  not keySizeSource.getScope().getScope*() instanceof TestScope
select keyGenOperation,
  "Creation of $@ key uses " + keyBitLength.toString() + " bits, which is below " +
    keyGenOperation.minimumSecureKeySize() + " and considered breakable.", 
  keySizeSource, keyGenOperation.getName()