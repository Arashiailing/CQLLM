/**
 * @name Detection of Symmetric Encryption with Padding Schemes
 * @description Identifies symmetric encryption algorithms that utilize padding schemes,
 *              which may be vulnerable to certain attacks in a quantum computing context.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Identify all symmetric encryption algorithms using padding schemes
from SymmetricPadding symmetricEncryptionWithPadding
select symmetricEncryptionWithPadding, "Detected algorithm with padding: " + symmetricEncryptionWithPadding.getPaddingName()