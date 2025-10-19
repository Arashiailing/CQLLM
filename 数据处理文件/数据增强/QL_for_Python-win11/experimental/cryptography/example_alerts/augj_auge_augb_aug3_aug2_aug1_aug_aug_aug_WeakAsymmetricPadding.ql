/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either cryptographically
 * weak or not recognized as secure by established security standards. The query
 * exclusively permits robust padding methods (OAEP, KEM, PSS) and flags all others
 * as potential security vulnerabilities.
 * 
 * Focuses on padding implementations vulnerable to cryptographic attacks in
 * asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

from AsymmetricPadding insecurePadding, string paddingName
where
  // Extract the padding algorithm identifier from the implementation
  paddingName = insecurePadding.getPaddingName()
  // Identify padding schemes that are not in the approved secure list
  and not paddingName = ["OAEP", "KEM", "PSS"]
select insecurePadding, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingName