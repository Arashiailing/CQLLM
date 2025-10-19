/**
 * @name CWE-310: Weak Sensitive Data Hashing
 * @category Cryptographic Issues
 * @description Detecting the use of weak hashing functions for sensitive data.
 * @id py/FortunaAccumulator
 */

import python
import experimental.cryptography.Concepts

from HashFunction hash, String data
where
  hash.isFortunaAccumulator() and
  hash.hash(data)
select hash, data, "Use of weak Fortuna Accumulator for hashing sensitive data."