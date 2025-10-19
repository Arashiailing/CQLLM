import python

/**
 * CWE-287: Improper Authentication
 * Detects cases where user input is used to authenticate without proper validation.
 */
class PamAuthorizationQuery extends Query {
  /**
   * Finds functions that handle user input for authentication.
   */
  Function getAuthenticationFunction() {
    return Function f |
      f.getName() = "authenticate" and
      exists(Call call |
        call.getCallee() = f and
        exists(Argument arg |
          arg.getCall() = call and
          arg.getValue() instanceof UserInput
        )
      )
  }

  /**
   * Finds functions that validate user input.
   */
  Function getValidationFunction() {
    return Function f |
      f.getName() = "validate" and
      exists(Call call |
        call.getCallee() = f and
        exists(Argument arg |
          arg.getCall() = call and
          arg.getValue() instanceof UserInput
        )
      )
  }

  /**
   * Main query to find authentication functions without validation.
   */
  Function getImproperAuthenticationFunction() {
    Function authFunc = getAuthenticationFunction() |
      not exists(Call call |
        call.getCallee() = getValidationFunction() and
        exists(Argument arg |
          arg.getCall() = call and
          arg.getValue() instanceof UserInput and
          arg.getValue().getAPrecedingElement() = authFunc.getAParameter()
        )
      )
  }

  /**
   * Entry point for the query.
   */
  override predicate run() {
    exists(Function func |
      func = getImproperAuthenticationFunction() and
      report(func, "Improper authentication detected. User input is used without proper validation.")
    )
  }
}