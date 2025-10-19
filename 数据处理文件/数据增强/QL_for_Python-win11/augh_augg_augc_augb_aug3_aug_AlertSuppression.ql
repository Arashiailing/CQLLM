/**
 * @name Alert Suppression Information
 * @description Identifies and details alert suppressions using 'noqa' directives in Python code,
 *              providing comprehensive location and coverage information.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment handling module
private import semmle.python.Comment as P

// Represents AST nodes with enhanced location tracking capabilities
class AstNode instanceof P::AstNode {
  // Check if node's location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(filePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Generate string representation of AST node
  string toString() { result = super.toString() }
}

// Represents location-aware single-line comments
class SingleLineComment instanceof P::Comment {
  // Verify comment location against given coordinates
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    super.getLocation().hasLocationInfo(filePath, beginLine, beginColumn, finishLine, finishColumn)
  }

  // Retrieve raw text content of comment
  string getText() { result = super.getContents() }

  // Provide string representation of comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template with custom node types
import AS::Make<AstNode, SingleLineComment>

/**
 * Represents suppression comments using 'noqa' directive. This directive is
 * recognized by both pylint and pyflakes, and should be respected by LGTM.
 */
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor: Identify comments matching noqa pattern
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Provide suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define code coverage scope for this suppression
  override predicate covers(
    string filePath, int beginLine, int beginColumn, int finishLine, int finishColumn
  ) {
    // Extract location details of the comment
    exists(int startLine, int endLine, int endCol |
      this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
      // Set coverage to entire line containing the comment
      beginLine = startLine and
      finishLine = endLine and
      beginColumn = 1 and
      finishColumn = endCol
    )
  }
}