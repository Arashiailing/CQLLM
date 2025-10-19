import python

/** 
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 */
class ReflectedXSS extends Vulnerability {
  /** 
   * The variable containing unescaped user input.
   */
  Variable inputVar;
  
  /** 
   * The function call writing the input to an HTTP response.
   */
  Call outputCall;

  create ReflectedXSS(Variable inputVar, Call outputCall) {
    // Identify potential user input sources (e.g., GET/POST parameters)
    exists (Call sourceCall |
      sourceCall.getTarget().getName() = "get" or 
      sourceCall.getTarget().getName() = "post" or 
      sourceCall.getTarget().getName() = "request" and
      inputVar.isAssignedTo(sourceCall.getArgument(0)) and
      sourceCall.getModule().getName() = "flask.request" or 
      sourceCall.getModule().getName() = "django.http.request"
    ) and
    
    // Track usage of the input in an HTTP response output
    (outputCall.getTarget().getName() = "write" or 
     outputCall.getTarget().getName() = "send" or 
     outputCall.getTarget().getName() = "render_template" or 
     outputCall.getTarget().getName() = "jsonify" or 
     outputCall.getTarget().getName() = "make_response") and
    
    // Ensure the input variable is directly used in the output
    inputVar.isUsedIn(outputCall.getArgument(0))
  }

  override string getMessage() {
    return format("Potential reflected XSS: Unescaped user input '%s' is directly used in an HTTP response.", inputVar.getName());
  }
}