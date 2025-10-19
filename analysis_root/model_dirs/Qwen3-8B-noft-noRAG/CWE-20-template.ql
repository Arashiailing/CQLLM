import python

/**
 * Detects Template Injection by identifying calls to template rendering functions
 * where user-controlled inputs are used without proper escaping.
 */
from TemplateRenderCall renderCall, Argument arg
where renderCall.getTemplateName() = "jinja2.Template"
   and arg.getSource().isUserInput()
   and not arg.isEscaped()
select renderCall, "Potential Template Injection: User input used in template without proper escaping."