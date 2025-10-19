/**
 * @name Weak or Unknown Asymmetric Padding Detection
 * @description
 * Identifies cryptographic implementations that utilize asymmetric padding algorithms
 * which are considered weak, unapproved, or have unknown security implications.
 * This analysis targets padding schemes that do not conform to established
 * secure standards (OAEP, KEM, PSS). The use of such insecure padding
 * mechanisms can lead to cryptographic vulnerabilities and overall
 * system compromise.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of approved secure padding algorithms
string getSecurePaddingAlgorithm() {
  result in ["OAEP", "KEM", "PSS"]
}

// Identify asymmetric padding schemes that are not in the secure list
from AsymmetricPadding insecurePaddingScheme, string paddingAlgorithmName
where 
  // Extract the name of the current padding algorithm
  paddingAlgorithmName = insecurePaddingScheme.getPaddingName()
  // Check if the algorithm is not among the approved secure padding methods
  and paddingAlgorithmName != getSecurePaddingAlgorithm()
select insecurePaddingScheme, "Detected usage of unapproved, weak, or unknown asymmetric padding algorithm: " + paddingAlgorithmName