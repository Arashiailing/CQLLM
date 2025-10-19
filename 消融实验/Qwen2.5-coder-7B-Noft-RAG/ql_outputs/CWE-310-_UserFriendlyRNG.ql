/**
* @name Weak Sensitive Data Hashing
* @category Cryptographic Issues
*
@description Using weak hashing functions to hash sensitive data can compromise the security of the data.
*
@id py/weak-sensitive-data-hashing
*
@tags security
*/
import python
import experimental.cryptography.HashFunctions
from HashFunction hashFunc, HashedData data
    where hashFunc.isWeak()
    and hashFunc.hashes(data)
    select hashFunc, data, "Using weak hashing function to hash sensitive data"