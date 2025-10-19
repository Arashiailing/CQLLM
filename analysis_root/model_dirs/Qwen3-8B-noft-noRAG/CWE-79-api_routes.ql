import python
import semmle.code.scalacode-scala.library.LibraryUtils

/**
 * Detects reflected XSS vulnerabilities by identifying cases where user input is directly written to HTTP responses without proper sanitization.
 */
class ReflectedXss extends SecurityHotspot {
  /**
   * The user input that could lead to XSS.
   */
  val userInput = parameter("userInput", "User input that may be untrusted")

  /**
   * The HTTP response content that includes the user input directly.
   */
  val httpResponseContent = parameter("httpResponseContent", "HTTP response content containing user input")

  from {
    // Find user input sources (e.g., request parameters, headers, etc.)
    (inputExpr: Expr) 
    where inputExpr.isCallTo("flask.request.args.get") or 
          inputExpr.isCallTo("flask.request.form.get") or 
          inputExpr.isCallTo("flask.request.values.get") or 
          inputExpr.isCallTo("request.GET.get") or 
          inputExpr.isCallTo("request.POST.get") or 
          inputExpr.isCallTo("request.COOKIES.get")
    
    // Find usage of user input in HTTP responses (e.g., return statements, print, etc.)
    (outputStmt: Stmt)
    where outputStmt.isReturnStmt() and 
          outputStmt.hasAncestor(Attr[HttpHandler]) and 
          outputStmt.returnExpr.toString().contains(inputExpr.toString())
  }
  
  select(outputStmt, "Potential reflected XSS vulnerability: User input is directly included in HTTP response without sanitization.")
}