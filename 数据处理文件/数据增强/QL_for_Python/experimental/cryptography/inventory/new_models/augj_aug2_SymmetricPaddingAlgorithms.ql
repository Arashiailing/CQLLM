/**
 * @name Symmetric Padding Schemes
 * @description Identifies all instances where padding schemes are utilized with symmetric encryption algorithms
 * @kind problem
 * @id py/quantum-readiness/cbom/symmetric-padding-schemes
 * @problem.severity error
 * @tags cbom
 *       cryptography
 */

import python
import experimental.cryptography.Concepts

// Retrieve all symmetric padding schemes detected in the codebase
from SymmetricPadding symmetricPadding

// Generate results including the padding scheme object and descriptive message
select symmetricPadding, 
       "Use of algorithm " + symmetricPadding.getPaddingName()