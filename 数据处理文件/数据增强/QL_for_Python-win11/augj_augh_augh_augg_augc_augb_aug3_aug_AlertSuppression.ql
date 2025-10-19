/**
 * @name Alert Suppression Information
 * @description Detects and documents alert suppressions via 'noqa' directives in Python code,
 *              providing detailed location and coverage analysis for security assessments.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL's alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment handling module
private import semmle.python.Comment as P

// Represents AST nodes with enhanced location tracking capabilities
class AstNode instanceof P::AstNode {
  // Verify node location against specified coordinates
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
  // Validate comment location against given coordinates
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
    // Extract location details of the suppression comment
    exists(int suppressionStartLine, int suppressionEndLine, int suppressionEndColumn |
      this.hasLocationInfo(filePath, suppressionStartLine, _, suppressionEndLine, suppressionEndColumn) and
      // Set coverage to entire line containing the suppression
      beginLine = suppressionStartLine and
      finishLine = suppressionEndLine and
      beginColumn = 1 and
      finishColumn = suppressionEndColumn
    )
  }
}