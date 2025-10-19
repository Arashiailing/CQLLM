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

from Cryptography::PublicKey::KeyGeneration cryptoKeyGen, DataFlow::Node keySizeOrigin
where
  // Extract cryptographic key length from generation context and source node
  exists(int keySizeBits |
    keySizeBits = cryptoKeyGen.getKeySizeWithOrigin(keySizeOrigin) and
    // Verify key length meets minimum security requirements
    keySizeBits < cryptoKeyGen.minimumSecureKeySize() and
    // Exclude test code from security analysis scope
    not keySizeOrigin.getScope().getScope*() instanceof TestScope
  )
select cryptoKeyGen,
  "Creation of $@ key uses " + 
    cryptoKeyGen.getKeySizeWithOrigin(keySizeOrigin).toString() + 
    " bits, which is below " + cryptoKeyGen.minimumSecureKeySize() + 
    " and considered breakable.", 
  keySizeOrigin, cryptoKeyGen.getName()