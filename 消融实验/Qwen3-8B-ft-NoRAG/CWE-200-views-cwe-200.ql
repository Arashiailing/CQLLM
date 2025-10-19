import python

/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Detects exposure of sensitive information through logging, print statements, or other output mechanisms.
 */
from PrintStatement ps, StringLiteral sl
where ps.getArgument(0).hasLiteralValue(sl) and sl.getValue().matches(".*(?:password|secret|token|key|cred|api_key|private_key|database_credentials|session_id|auth_token|otp|ssn|credit_card|paypal|bitcoin|wallet|pin|passphrase|private|sensitive).*")
select ps, "Potential exposure of sensitive information in output: " + sl.getValue(), ps.getLocation()