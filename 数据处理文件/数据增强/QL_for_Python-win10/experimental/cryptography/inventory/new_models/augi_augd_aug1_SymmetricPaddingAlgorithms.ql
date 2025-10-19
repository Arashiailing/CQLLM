/**
 * @name Symmetric Encryption Padding Schemes Detection
 * @description Identifies cryptographic padding schemes used with symmetric encryption algorithms,
 *              which may impact cryptographic security and compliance.
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

from SymmetricPadding paddingScheme
select paddingScheme, 
       "Algorithm in use: " + paddingScheme.getPaddingName()