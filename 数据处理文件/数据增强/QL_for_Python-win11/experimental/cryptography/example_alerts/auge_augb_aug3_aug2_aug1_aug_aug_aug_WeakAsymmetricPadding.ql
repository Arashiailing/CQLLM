/**
 * @name Weak or unknown asymmetric padding
 * @description
 * This query detects asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * security standards. By exclusively permitting the most robust padding methods
 * (OAEP, KEM, PSS), the analysis identifies and flags all other padding configurations
 * as potential security vulnerabilities.
 * 
 * The analysis specifically focuses on padding implementations that could be
 * vulnerable to cryptographic attacks in asymmetric encryption contexts.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of approved secure padding methods for asymmetric encryption
// Only these specific padding techniques are considered cryptographically secure
from AsymmetricPadding vulnerablePaddingScheme, string paddingAlgorithm
where
  // Extract the padding algorithm identifier from the implementation
  paddingAlgorithm = vulnerablePaddingScheme.getPaddingName()
  // Identify padding schemes that are not in the approved secure list
  and not paddingAlgorithm = ["OAEP", "KEM", "PSS"]
select vulnerablePaddingScheme, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingAlgorithm