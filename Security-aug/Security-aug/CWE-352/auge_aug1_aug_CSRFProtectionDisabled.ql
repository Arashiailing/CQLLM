/**
 * @name CSRF protection weakened or disabled
 * @description Detects configurations where Cross-Site Request Forgery (CSRF) protection
 *              has been disabled or weakened, making the application vulnerable to
 *              unauthorized actions performed on behalf of authenticated users.
 * @kind problem
 * @problem.severity warning
 * @security-severity 8.8
 * @precision high
 * @id py/csrf-protection-disabled
 * @tags security
 *       external/cwe/cwe-352
 */

// Import standard Python libraries and security-related concepts
import python
import semmle.python.Concepts

// Predicate that excludes CSRF configurations found in test files to reduce false positives
predicate isProductionCsrfConfig(Http::Server::CsrfProtectionSetting csrfConfig) {
  // Filter out configurations located in test files based on path analysis
  not csrfConfig.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate that identifies CSRF configurations lacking adequate protection mechanisms
predicate lacksAdequateCsrfProtection(Http::Server::CsrfProtectionSetting csrfConfig) {
  // Condition 1: CSRF verification is explicitly turned off
  csrfConfig.getVerificationSetting() = false and
  // Condition 2: No alternative local CSRF protection is implemented
  not exists(Http::Server::CsrfLocalProtectionSetting localProtection | localProtection.csrfEnabled()) and
  // Condition 3: The configuration is part of production code (not test code)
  isProductionCsrfConfig(csrfConfig)
}

// Predicate that verifies all production CSRF configurations are vulnerable
// This reduces false positives by ensuring there are no secure configurations in production
predicate allProductionConfigsAreVulnerable() {
  not exists(Http::Server::CsrfProtectionSetting secureConfig |
    // Check if the configuration is for production
    isProductionCsrfConfig(secureConfig) and
    // And it's not vulnerable (i.e., it's secure)
    not lacksAdequateCsrfProtection(secureConfig)
  )
}

// Main query that identifies CSRF vulnerabilities in the application
from Http::Server::CsrfProtectionSetting csrfConfig
where
  // Condition 1: The configuration must lack adequate CSRF protection
  lacksAdequateCsrfProtection(csrfConfig) and
  // Condition 2: Ensure there are no secure production configurations to minimize false positives
  allProductionConfigsAreVulnerable()
select csrfConfig, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."