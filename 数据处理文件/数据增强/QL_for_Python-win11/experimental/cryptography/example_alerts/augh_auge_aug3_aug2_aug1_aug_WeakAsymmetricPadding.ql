/**
 * @name Detection of weak or unknown asymmetric padding
 * @description
 * This analysis targets asymmetric cryptographic padding schemes that are
 * deemed insecure, not suitable for security-critical applications, or lack
 * adequate security evaluation. The query specifically flags any padding
 * techniques other than OAEP (Optimal Asymmetric Encryption Padding),
 * KEM (Key Encapsulation Mechanism), and PSS (Probabilistic Signature Scheme),
 * which are the only padding methods currently recognized as secure for
 * asymmetric cryptographic operations. Using alternative padding methods
 * may introduce security vulnerabilities and should be replaced with
 * these recommended algorithms.
 * @id py/weak-asymmetric-padding
 * @kind problem
 * @problem.severity error
 * @precision high
 */

import python
import experimental.cryptography.Concepts

// Identify asymmetric padding implementations that are not considered secure
from AsymmetricPadding insecurePadding, string algorithmName
where 
  // Extract the name of the padding algorithm in use
  algorithmName = insecurePadding.getPaddingName()
  // Exclude the approved secure padding methods from the results
  and not algorithmName.matches("OAEP|KEM|PSS")
select insecurePadding, "Use of unapproved, weak, or unknown asymmetric padding algorithm or API: " + algorithmName