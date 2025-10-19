/**
 * @name Weak or unknown asymmetric padding
 * @description
 * This query detects padding schemes in asymmetric encryption that are considered
 * cryptographically inadequate or not compliant with established security standards.
 * The analysis employs a whitelist methodology, only recognizing proven secure
 * padding techniques (OAEP, KEM, PSS) while identifying all alternative schemes
 * as potential security risks.
 * 
 * The detection specifically targets padding implementations that could be
 * vulnerable to cryptographic attacks when utilized in asymmetric encryption scenarios.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define secure padding algorithms that are considered cryptographically strong
string securePaddingScheme() {
  result = ["OAEP", "KEM", "PSS"]
}

// Detect and report insecure padding implementations for asymmetric encryption
from AsymmetricPadding insecurePadding, string paddingSchemeName
where
  // Retrieve the algorithm name from the padding implementation
  paddingSchemeName = insecurePadding.getPaddingName()
  // Exclude padding schemes that are considered secure
  and not paddingSchemeName = securePaddingScheme()
select insecurePadding, "Detected unapproved, weak, or unknown asymmetric padding algorithm: " + paddingSchemeName