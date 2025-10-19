/**
 * @name Alert Suppression Information
 * @description Identifies and analyzes alert suppressions in Python code using 'noqa' directives.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment handling module
private import semmle.python.Comment as P

// Represents AST nodes with location tracking capabilities
class AstNode instanceof P::AstNode {
  // Check if node location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Provide string representation of AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with location information
class SingleLineComment instanceof P::Comment {
  // Verify if comment location matches given coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Retrieve text content of the comment
  string getText() { result = super.getContents() }

  // Return string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents suppression comments using 'noqa' directive. This directive is recognized by 
 * pylint and pyflakes, and should be respected by LGTM for alert suppression.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Identify comments matching noqa pattern
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Provide suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define code coverage scope for this suppression
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Get comment location details
    exists(int commentStartLine, int commentEndLine, int commentEndCol |
      this.hasLocationInfo(filePath, commentStartLine, _, commentEndLine, commentEndCol) and
      // Set coverage to entire line containing comment
      startLine = commentStartLine and
      endLine = commentEndLine and
      startCol = 1 and
      endCol = commentEndCol
    )
  }
}