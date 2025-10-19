/**
 * @name Use of weak cryptographic key
 * @description Use of a cryptographic key that is too small may allow the encryption to be broken.
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

// 从Cryptography::PublicKey::KeyGeneration类中导入keyGen，int类型的keySize和DataFlow::Node类型的origin
from Cryptography::PublicKey::KeyGeneration keyGen, int keySize, DataFlow::Node origin