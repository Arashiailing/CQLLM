/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding mechanisms that are either
 * cryptographically insecure or not explicitly recognized as secure by
 * established security standards. This analysis excludes approved padding
 * methods (OAEP, KEM, PSS) and highlights all other padding schemes as
 * potential security risks.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define secure padding schemes that should not be flagged
string securePaddingScheme() { result = ["OAEP", "KEM", "PSS"] }

// Identify asymmetric padding implementations and their scheme names
from AsymmetricPadding asymmetricPadding, string paddingScheme
where
  // Extract the padding scheme name from the implementation
  paddingScheme = asymmetricPadding.getPaddingName()
  // Filter out known secure padding schemes
  and not paddingScheme = securePaddingScheme()
select asymmetricPadding, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + paddingScheme