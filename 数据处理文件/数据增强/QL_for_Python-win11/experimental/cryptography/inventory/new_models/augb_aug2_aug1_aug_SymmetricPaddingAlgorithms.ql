/**
 * @name Detection of Symmetric Encryption with Padding Schemes
 * @description This query identifies symmetric encryption implementations that employ padding mechanisms.
 *              In the context of quantum readiness, padding schemes can introduce vulnerabilities that may be
 *              exacerbated by quantum computing capabilities. Traditional symmetric encryption with padding
 *              may not provide sufficient security against quantum attacks, making it important to identify
 *              and potentially replace these implementations with quantum-resistant alternatives.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding paddedSymmetricCipher
select paddedSymmetricCipher, 
       "Identified symmetric encryption with padding: " + paddedSymmetricCipher.getPaddingName()