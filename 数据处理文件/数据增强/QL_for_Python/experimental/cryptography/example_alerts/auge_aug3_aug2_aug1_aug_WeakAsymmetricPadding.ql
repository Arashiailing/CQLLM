/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * This query identifies asymmetric cryptographic padding algorithms that are
 * considered insecure, not recommended for secure applications, or have
 * insufficient security analysis. Only OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme)
 * padding methods are recognized as secure for asymmetric cryptographic operations.
 * Any other padding techniques could potentially introduce security weaknesses
 * and should be substituted with these approved algorithms.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Find implementations of asymmetric padding that are not secure
from AsymmetricPadding insecureAsymmetricPadding, string paddingAlgorithmName
where 
  // Obtain the name of the padding algorithm being used
  paddingAlgorithmName = insecureAsymmetricPadding.getPaddingName()
  // Filter out the approved secure padding methods
  and not paddingAlgorithmName.matches("OAEP|KEM|PSS")
select insecureAsymmetricPadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + paddingAlgorithmName