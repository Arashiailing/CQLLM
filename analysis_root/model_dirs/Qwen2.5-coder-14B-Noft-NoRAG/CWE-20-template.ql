import python

/**
 * A query to detect CWE-20: Improper Input Validation
 * This query looks for cases where user input is directly used in a template without proper validation.
 */

from TemplateCall templateCall, Expr userInput
where templateCall.getTemplate().(StringLiteral).getValue() = "%s"
  and templateCall.getArgs()[0] = userInput
select userInput, "User input is directly used in a template without proper validation."