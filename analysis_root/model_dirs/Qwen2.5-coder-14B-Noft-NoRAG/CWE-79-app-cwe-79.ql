import python

/**
 * This query detects potential Reflected XSS vulnerabilities in Python web applications.
 * It looks for cases where user input is directly written to the HTTP response without proper sanitization.
 */

class ReflectedXssQuery extends QlQuery {
  /**
   * The main entry point for the query.
   */
  ReflectedXssQuery() {
    this.getName() = "Reflected server-side cross-site scripting"
    this.getDescription() = "Writing user input directly to a web page allows for a cross-site scripting vulnerability."
    this.getId() = "py/app-cwe-79"
  }

  /**
   * Finds potential XSS vulnerabilities.
   */
  ReflectedXssQuery() {
    from WebRequest req, WebResponse res, DataFlow::Node sink
    where sink instanceof WebResponse::ContentNode and
          sink.hasSource(req.getUserInput()) and
          not sink.isSanitized()
    select sink, "Potential reflected XSS vulnerability: User input is directly written to the HTTP response without proper sanitization."
  }
}