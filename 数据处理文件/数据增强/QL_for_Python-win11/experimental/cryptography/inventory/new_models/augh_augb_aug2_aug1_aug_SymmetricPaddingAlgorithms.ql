/**
 * @name Detection of Symmetric Encryption with Padding Schemes
 * @description Identifies symmetric encryption implementations that utilize padding mechanisms.
 *              Padding schemes in symmetric encryption can introduce vulnerabilities that may be
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

from SymmetricPadding symmetricCipherWithPadding
select symmetricCipherWithPadding,
       "Identified symmetric encryption with padding: " + symmetricCipherWithPadding.getPaddingName()