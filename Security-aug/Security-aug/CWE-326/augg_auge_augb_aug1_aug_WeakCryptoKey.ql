/**
 * @name Insufficient cryptographic key strength
 * @description Detects cryptographic keys that are generated with bit lengths too short to resist brute-force attacks.
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

from Cryptography::PublicKey::KeyGeneration keyGenerator, DataFlow::Node keySizeSource
where
  // Check if a cryptographic key is generated with insufficient bit length
  exists(int keyBitLength |
    // Extract the key bit length from the generation context
    keyBitLength = keyGenerator.getKeySizeWithOrigin(keySizeSource) and
    // Verify if the key length is below the minimum secure threshold
    keyBitLength < keyGenerator.minimumSecureKeySize() and
    // Exclude test code from security analysis
    not keySizeSource.getScope().getScope*() instanceof TestScope
  )
select keyGenerator,
  "Generation of $@ key with " + 
    keyGenerator.getKeySizeWithOrigin(keySizeSource).toString() + 
    " bits is insecure; minimum recommended is " + keyGenerator.minimumSecureKeySize() + 
    " bits.", 
  keySizeSource, keyGenerator.getName()