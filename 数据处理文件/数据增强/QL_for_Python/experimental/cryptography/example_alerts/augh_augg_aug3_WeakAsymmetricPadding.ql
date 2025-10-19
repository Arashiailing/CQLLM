/**
 * @name Detection of weak or unidentified asymmetric padding
 * @description
 * Identifies cryptographic implementations using asymmetric padding schemes that are
 * either weak, unapproved, or unrecognized. Approved secure padding includes OAEP,
 * KEM, and PSS. Other schemes may introduce cryptographic vulnerabilities.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define approved secure padding schemes
string secureScheme() { result = ["OAEP", "KEM", "PSS"] }

// Identify vulnerable asymmetric padding implementations
from AsymmetricPadding vulnerablePadding

// Check padding scheme against approved list
where exists(string paddingName | 
    paddingName = vulnerablePadding.getPaddingName() and
    not paddingName = secureScheme()
)

// Report findings with scheme identification
select vulnerablePadding, 
       "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + 
       vulnerablePadding.getPaddingName()