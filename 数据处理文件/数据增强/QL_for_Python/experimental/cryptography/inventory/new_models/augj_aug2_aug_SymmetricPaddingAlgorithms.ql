/**
 * @name Symmetric Encryption Padding Detection
 * @description Identifies symmetric encryption algorithms using padding schemes
 *              that may be vulnerable to cryptographic attacks
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
       "Algorithm using padding scheme: " + paddingScheme.getPaddingName()