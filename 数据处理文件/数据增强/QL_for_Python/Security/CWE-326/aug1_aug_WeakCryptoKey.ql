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

from Cryptography::PublicKey::KeyGeneration cryptoKeyGeneration, int actualKeyLength, DataFlow::Node keyLengthSource
where
  // Extract key bit length from generation context and source node
  actualKeyLength = cryptoKeyGeneration.getKeySizeWithOrigin(keyLengthSource)
  and
  // Validate key length against minimum security requirements
  actualKeyLength < cryptoKeyGeneration.minimumSecureKeySize()
  and
  // Exclude test code from security analysis scope
  not keyLengthSource.getScope().getScope*() instanceof TestScope
select cryptoKeyGeneration,
  "Creation of $@ key uses " + actualKeyLength.toString() + " bits, which is below " +
    cryptoKeyGeneration.minimumSecureKeySize() + " and considered breakable.", 
  keyLengthSource, cryptoKeyGeneration.getName()