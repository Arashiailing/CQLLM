/**
 * @name Weak or unknown asymmetric padding
 * @description
 * Detects asymmetric encryption padding schemes that are either
 * cryptographically weak or not explicitly recognized as secure by established
 * cryptographic standards. This analysis identifies padding configurations that
 * may introduce security vulnerabilities by only allowing the strongest padding
 * methods (OAEP, KEM, PSS) and flagging all others as potential security risks.
 * 
 * The query specifically targets padding implementations that could be
 * susceptible to cryptographic attacks in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically approved padding schemes
// These padding methods are considered secure for asymmetric cryptographic operations
from AsymmetricPadding paddingAlgorithm, string paddingSchemeName
where
  // Extract the name of the padding algorithm from the implementation
  paddingSchemeName = paddingAlgorithm.getPaddingName()
  // Check if the padding scheme is not in the list of approved secure methods
  and not paddingSchemeName = ["OAEP", "KEM", "PSS"]
select paddingAlgorithm, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingSchemeName