/**
 * @name Symmetric Encryption with Padding Schemes Detection
 * @description Identifies symmetric encryption implementations that utilize padding mechanisms.
 *              In quantum computing contexts, padding schemes can introduce security vulnerabilities
 *              that may be amplified by quantum capabilities. Traditional symmetric encryption with
 *              padding may not provide adequate protection against quantum attacks, necessitating
 *              identification and potential replacement with quantum-resistant alternatives.
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
       "Detected symmetric encryption using padding: " + symmetricCipherWithPadding.getPaddingName()