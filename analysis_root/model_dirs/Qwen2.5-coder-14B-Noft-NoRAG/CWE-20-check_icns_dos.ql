import python

/**
 * Detects CWE-20: Improper Input Validation
 * The query searches for functions that perform regular expression matching
 * without proper input validation, which can lead to Denial of Service (DoS)
 * attacks due to excessive CPU consumption.
 */

class PolynomialReDoSQuery extends Query {
  PolynomialReDoSQuery() {
    this.getName() = "CWE-20: Improper Input Validation"
    this.getDescription() = "The product receives input or data, but it does not validate or incorrectly validates that the input has the properties that are required to process the data safely and correctly."
    this.getId() = "py/check_icns_dos"
  }

  override predicate execute() {
    // Find all function calls to re.match or re.search
    from FunctionCall fc, Function f
    where fc.getTarget() = f and (f.getName() = "match" or f.getName() = "search") and f.getModule().getName() = "re"
    // Check if the function call does not have proper input validation
    and not exists(InputValidation iv | iv.getFunctionCall() = fc)
    select fc, "This function call to re.match or re.search does not have proper input validation, which can lead to a Polynomial ReDoS vulnerability."
  }
}

class InputValidation {
  FunctionCall getFunctionCall() {... }
}