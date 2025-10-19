/**
 * @name Alert Suppression Information
 * @description Identifies and analyzes alert suppression patterns in Python code
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import CodeQL alert suppression utilities
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing module
private import semmle.python.Comment as P

// Represents AST nodes equipped with location tracking capabilities
class NodeWithLocation instanceof P::AstNode {
  // Verify node location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, beginLine, beginCol, endLine, endCol)
  }

  // Generate string representation of the node
  string toString() { result = super.toString() }
}

// Represents single-line comments with enhanced location tracking
class CommentWithLocation instanceof P::Comment {
  // Verify comment location matches specified coordinates
  predicate hasLocationInfo(
    string filePath, int beginLine, int beginCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, beginLine, beginCol, endLine, endCol)
  }

  // Extract text content from the comment
  string getText() { result = super.getContents() }

  // Generate string representation of the comment
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template with location-aware nodes
import AS::Make<NodeWithLocation, CommentWithLocation>

/**
 * A noqa-style suppression comment. Recognized by both pylint and pyflakes,
 * and therefore supported by lgtm analysis.
 */
// Represents suppression comments following the noqa convention
class NoqaStyleSuppression extends SuppressionComment instanceof CommentWithLocation {
  // Initialize by detecting noqa comment pattern
  NoqaStyleSuppression() {
    CommentWithLocation.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define the code coverage scope for this suppression
  override predicate covers(
    string filePath, int beginLine, int beginCol, int endLine, int endCol
  ) {
    // Extract precise location details from the comment
    exists(int commentStartLine, int commentEndLine, int commentEndColumn |
      this.hasLocationInfo(filePath, commentStartLine, _, commentEndLine, commentEndColumn) and
      // Align coverage boundaries with comment location
      beginLine = commentStartLine and
      endLine = commentEndLine and
      beginCol = 1 and
      endCol = commentEndColumn
    )
  }
}