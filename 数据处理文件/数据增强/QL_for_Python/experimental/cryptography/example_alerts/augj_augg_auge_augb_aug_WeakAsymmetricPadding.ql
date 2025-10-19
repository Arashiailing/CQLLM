/**
 * @name Detection of insecure asymmetric cryptographic padding schemes
 * @description
 * This query identifies asymmetric cryptographic padding implementations that are classified as
 * vulnerable, disallowed for security-critical applications, or have ambiguous security properties.
 * Secure cryptographic systems should exclusively utilize specific padding techniques. The
 * approved secure asymmetric padding methods include:
 * - OAEP (Optimal Asymmetric Encryption Padding)
 * - KEM (Key Encapsulation Mechanism)
 * - PSS (Probabilistic Signature Scheme)
 * Utilization of alternative padding approaches may introduce security vulnerabilities. This analysis
 * helps detect such potentially insecure padding choices by flagging any asymmetric padding method
 * that falls outside the list of approved secure techniques.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Define the set of approved secure padding methods
// These are the only padding techniques considered secure for asymmetric cryptographic operations
from AsymmetricPadding insecurePaddingMethod, string paddingMethodName
where 
  // Extract the name of the padding algorithm being used
  paddingMethodName = insecurePaddingMethod.getPaddingName()
  // Ensure the algorithm is not one of the approved secure padding methods
  and not paddingMethodName in ["OAEP", "KEM", "PSS"]
select insecurePaddingMethod, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingMethodName