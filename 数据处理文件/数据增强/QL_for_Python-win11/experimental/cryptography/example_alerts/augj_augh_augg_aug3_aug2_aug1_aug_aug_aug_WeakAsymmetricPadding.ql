/**
 * @name Vulnerable asymmetric encryption padding
 * @description
 * This security analysis identifies potentially insecure padding schemes used in
 * asymmetric encryption implementations. The query operates on a whitelist-based
 * security model, where only explicitly approved padding methods (OAEP, KEM, PSS)
 * are considered secure. Any other padding algorithm is flagged as a potential
 * security vulnerability.
 * 
 * The detection mechanism focuses on identifying padding implementations that
 * may be susceptible to cryptographic attacks when deployed in asymmetric
 * encryption contexts, helping developers maintain strong cryptographic standards.
 * 
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of cryptographically secure padding algorithms
// that are approved for use in asymmetric encryption scenarios
string getSecurePaddingAlgorithm() { 
  result = ["OAEP", "KEM", "PSS"] 
}

// Identify and analyze asymmetric encryption padding implementations
// that do not use approved security standards
from AsymmetricPadding vulnerablePaddingScheme, string paddingAlgorithm
where
  // Extract the algorithm identifier from the padding implementation
  paddingAlgorithm = vulnerablePaddingScheme.getPaddingName()
  // Filter out implementations using secure padding methods
  and not paddingAlgorithm = getSecurePaddingAlgorithm()
select vulnerablePaddingScheme, "Identified unapproved, weak, or unknown asymmetric padding algorithm: " + paddingAlgorithm