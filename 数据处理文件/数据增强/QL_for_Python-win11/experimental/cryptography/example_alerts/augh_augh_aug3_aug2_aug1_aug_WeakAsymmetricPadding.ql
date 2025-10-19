/**
 * @name Detection of insecure asymmetric cryptographic padding
 * @description
 * This query identifies asymmetric encryption padding methods that are considered insecure,
 * deprecated, or have unclear security implications. In modern cryptographic practices,
 * only OAEP (Optimal Asymmetric Encryption Padding), KEM (Key Encapsulation Mechanism),
 * and PSS (Probabilistic Signature Scheme) are recognized as secure padding schemes for
 * asymmetric cryptography. Any other padding method may introduce security vulnerabilities
 * and should be replaced with one of the approved algorithms.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// This query detects asymmetric cryptographic padding schemes that are not secure
from AsymmetricPadding insecurePaddingMethod, string paddingAlgorithmName
where 
  // Step 1: Obtain the name of the padding algorithm being used
  paddingAlgorithmName = insecurePaddingMethod.getPaddingName()
  // Step 2: Verify that the padding scheme is not one of the approved secure algorithms
  and not (paddingAlgorithmName = "OAEP" or 
           paddingAlgorithmName = "KEM" or 
           paddingAlgorithmName = "PSS")
select insecurePaddingMethod, "Detected use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName