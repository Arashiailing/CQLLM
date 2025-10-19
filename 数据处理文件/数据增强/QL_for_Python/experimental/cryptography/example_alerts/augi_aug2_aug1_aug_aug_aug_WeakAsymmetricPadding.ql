/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * security standards. This analysis flags potentially vulnerable padding configurations
 * by permitting only the most robust padding methods (OAEP, KEM, PSS) and marking
 * all other schemes as potential security risks.
 * 
 * The query specifically focuses on padding implementations that could be vulnerable
 * to cryptographic attacks when used in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define cryptographically secure padding schemes for asymmetric encryption
// These specific padding techniques are considered secure for asymmetric encryption
from AsymmetricPadding insecurePaddingScheme, string schemeName
where
  // Extract the padding algorithm identifier from the implementation
  schemeName = insecurePaddingScheme.getPaddingName()
  // Filter out implementations using secure padding methods
  and not schemeName in ["OAEP", "KEM", "PSS"]
select insecurePaddingScheme, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + schemeName