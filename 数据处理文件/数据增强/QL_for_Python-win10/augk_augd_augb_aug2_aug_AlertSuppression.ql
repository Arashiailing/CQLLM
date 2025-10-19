/**
 * @name Alert suppression
 * @description Comprehensive analysis of alert suppression mechanisms in Python code
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL's alert suppression utilities for managing suppression logic
private import codeql.util.suppression.AlertSuppression as SuppressionUtils
// Import Python comment processing utilities for comment analysis
private import semmle.python.Comment as PythonComment

// Represents AST nodes with enhanced location tracking capabilities
class AstNode instanceof PythonComment::AstNode {
  // Generate string representation of the AST node
  string toString() { result = super.toString() }

  // Verify if the node's location matches specified coordinates
  predicate hasLocationInfo(
    string sourcePath, int beginLine, int beginColumn, int conclusionLine, int conclusionColumn
  ) {
    super.getLocation().hasLocationInfo(sourcePath, beginLine, beginColumn, conclusionLine, conclusionColumn)
  }
}

// Represents single-line comments with precise location tracking
class SingleLineComment instanceof PythonComment::Comment {
  // Generate string representation of the comment
  string toString() { result = super.toString() }

  // Retrieve the textual content of the comment
  string getText() { result = super.getContents() }

  // Verify if the comment's location matches specified coordinates
  predicate hasLocationInfo(
    string sourcePath, int beginLine, int beginColumn, int conclusionLine, int conclusionColumn
  ) {
    super.getLocation().hasLocationInfo(sourcePath, beginLine, beginColumn, conclusionLine, conclusionColumn)
  }
}

// Generate suppression relationships using the AlertSuppUtil template
import SuppressionUtils::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment. Recognized by both pylint and pyflakes,
 * and therefore should be respected by lgtm.
 */
// Denotes suppression comments following the noqa standard
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor identifying noqa comment patterns
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Provides the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Defines the code coverage range for this suppression annotation
  override predicate covers(
    string sourcePath, int beginLine, int beginColumn, int conclusionLine, int conclusionColumn
  ) {
    // Ensure the comment's location matches and starts at line beginning
    this.hasLocationInfo(sourcePath, beginLine, _, conclusionLine, conclusionColumn) and
    beginColumn = 1
  }
}