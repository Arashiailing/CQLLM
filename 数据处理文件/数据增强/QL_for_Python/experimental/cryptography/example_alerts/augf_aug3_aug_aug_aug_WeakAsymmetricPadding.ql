/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Identifies asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly approved by security standards.
 * 
 * This analysis flags padding configurations that could be vulnerable to
 * cryptographic attacks by excluding only the most secure padding methods
 * (OAEP, KEM, PSS) and treating all other padding schemes as potential risks.
 * 
 * The query specifically targets asymmetric encryption implementations
 * where padding choice is critical for security.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define cryptographically secure padding schemes for asymmetric encryption
from AsymmetricPadding paddingScheme, string algorithmName
where
  // Extract the padding algorithm name from the implementation
  algorithmName = paddingScheme.getPaddingName()
  // Flag implementations using non-approved padding schemes
  and not algorithmName = ["OAEP", "KEM", "PSS"]
select paddingScheme, "Unapproved, weak, or unknown asymmetric padding algorithm detected: " + algorithmName