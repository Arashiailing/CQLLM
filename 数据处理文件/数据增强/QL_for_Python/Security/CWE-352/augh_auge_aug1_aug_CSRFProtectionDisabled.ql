/**
 * @name CSRF protection weakened or disabled
 * @description Identifies application configurations where Cross-Site Request Forgery (CSRF) 
 *              protection mechanisms have been turned off or weakened, potentially allowing 
 *              attackers to execute unauthorized actions on behalf of authenticated users.
 * @kind problem
 * @problem.severity warning
 * @security-severity 8.8
 * @precision high
 * @id py/csrf-protection-disabled
 * @tags security
 *       external/cwe/cwe-352
 */

// Import required Python libraries and security analysis components
import python
import semmle.python.Concepts

// Helper predicate to determine if a CSRF configuration is in production code (excludes test files)
predicate isInProductionCode(Http::Server::CsrfProtectionSetting csrfProtectionSetting) {
  // Exclude configurations located in test files based on file path analysis
  not csrfProtectionSetting.getLocation().getFile().getAbsolutePath().matches("%test%")
}

// Predicate that identifies CSRF configurations without proper security measures
predicate hasInsufficientCsrfProtection(Http::Server::CsrfProtectionSetting csrfProtectionSetting) {
  // Check if CSRF verification is explicitly disabled
  csrfProtectionSetting.getVerificationSetting() = false and
  // Verify no alternative local CSRF protection mechanism is in place
  not exists(Http::Server::CsrfLocalProtectionSetting localCsrfProtection | localCsrfProtection.csrfEnabled()) and
  // Ensure the configuration is part of production code, not test code
  isInProductionCode(csrfProtectionSetting)
}

// Predicate that confirms all production CSRF configurations are vulnerable
// This helps reduce false positives by ensuring no secure configurations exist in production
predicate allProductionSettingsAreVulnerable() {
  not exists(Http::Server::CsrfProtectionSetting secureCsrfSetting |
    // Verify the configuration is for production code
    isInProductionCode(secureCsrfSetting) and
    // And it does not have insufficient protection (i.e., it's secure)
    not hasInsufficientCsrfProtection(secureCsrfSetting)
  )
}

// Main query that detects CSRF vulnerabilities in the application configuration
from Http::Server::CsrfProtectionSetting csrfProtectionSetting
where
  // The configuration must have insufficient CSRF protection
  hasInsufficientCsrfProtection(csrfProtectionSetting) and
  // Ensure no secure production configurations exist to minimize false positive reports
  allProductionSettingsAreVulnerable()
select csrfProtectionSetting, "Potential CSRF vulnerability due to forgery protection being disabled or weakened."