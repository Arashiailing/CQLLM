/**
 * @name Use of weak cryptographic key
 * @description Use of a cryptographic key that is too small may allow the encryption to be broken.
 * @id py/httpauth.nim
 */

import python
import experimental.semmle.python.security.Hashing
import semmle.python.dataflow.new.DataFlow

predicate isWeakKey(int keySize) {
  keySize < 256
}

from HashAlgorithm alg, DataFlow::Node node
where alg.isWeakHash() and
      exists(DataFlow::Flow flow | flow.getSource() = node and flow.getSink() = alg)
select alg, node, "Weak cryptographic key used in hashing algorithm"