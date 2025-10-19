import python
import swift

/**
 * @name CWE-200: Exposure of Sensitive Information to an Unauthorized Actor
 * @description Detects potential exposure of sensitive information via logging in Python and Swift.
 */
class Cwe200Exposure {
  /**
   * Checks for logging calls with arguments containing sensitive keywords.
   */
  predicate hasSensitiveLogArg(Argument arg) {
    let sensitiveKeywords = ["password", "secret", "token", "key", "api", "credential"]
    exists (StringLiteral sl |
      arg.expr = sl and sl.value contains any sensitiveKeyword in sensitiveKeywords
    ) or
    exists (Variable v |
      arg.expr = v and v.name matches /.*(?:password|secret|token|key|api|credential).*/
    )
  }

  /**
   * Main query to detect CWE-200 vulnerabilities.
   */
  from Call call, Argument arg
  where (call.isPython() and hasSensitiveLogArg(arg)) or
        (call.isSwift() and hasSensitiveLogArg(arg))
  select call, "Potential exposure of sensitive information through logging."
}