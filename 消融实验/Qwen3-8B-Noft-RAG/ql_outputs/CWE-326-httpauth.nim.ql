import python
import semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow

from Cryptography::PublicKey::KeyGeneration keyGen, int keySize, DataFlow::Node origin
where keySize < 2048
select origin, "Use of weak cryptographic key with size $@ bits", keySize