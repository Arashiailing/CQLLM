/**
 * @name Detection of Symmetric Encryption with Padding Schemes
 * @description This query identifies symmetric encryption algorithms that employ padding schemes.
 *              Such implementations may be susceptible to cryptographic attacks like padding oracle attacks.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding symmetricEncryptionWithPadding
select symmetricEncryptionWithPadding, 
       "Detected symmetric encryption algorithm using padding: " + 
       symmetricEncryptionWithPadding.getPaddingName()