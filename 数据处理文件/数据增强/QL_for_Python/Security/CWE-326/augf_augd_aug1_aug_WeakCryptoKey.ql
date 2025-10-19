/**
 * @name Weak cryptographic key usage
 * @description Identifies cryptographic key generation operations using insufficient key lengths
 *              vulnerable to brute-force attacks
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

from Cryptography::PublicKey::KeyGeneration cryptoKeyGen, int actualKeyBits, DataFlow::Node keySizeParamNode
where
  // Extract key bit length and its source node from the cryptographic operation
  actualKeyBits = cryptoKeyGen.getKeySizeWithOrigin(keySizeParamNode)
  and
  // Validate key length against minimum security requirements
  actualKeyBits < cryptoKeyGen.minimumSecureKeySize()
  and
  // Exclude test code to focus on production implementations
  not keySizeParamNode.getScope().getScope*() instanceof TestScope
select cryptoKeyGen,
  "Creation of $@ key uses " + actualKeyBits.toString() + " bits, which is below " +
    cryptoKeyGen.minimumSecureKeySize() + " and considered breakable.", 
  keySizeParamNode, cryptoKeyGen.getName()