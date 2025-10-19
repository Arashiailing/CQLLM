/**
 * @name Detection of weak or unidentified asymmetric padding
 * @description
 * This query identifies cryptographic implementations that utilize asymmetric padding schemes
 * which are either weak, not approved, or unrecognized. Secure padding schemes such as OAEP,
 * KEM, and PSS are considered safe, whereas other schemes may introduce vulnerabilities.
 * Detection of these insecure padding practices is crucial for maintaining cryptographic security.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Step 1: Identify all asymmetric padding implementations
from AsymmetricPadding insecurePadding

// Step 2: Extract the name of the padding scheme
where exists(string schemeName | 
    schemeName = insecurePadding.getPaddingName() and

    // Step 3: Verify the scheme is not in the approved secure list
    not schemeName in ["OAEP", "KEM", "PSS"]
)

// Report findings with contextual information
select insecurePadding, 
       "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + 
       insecurePadding.getPaddingName()