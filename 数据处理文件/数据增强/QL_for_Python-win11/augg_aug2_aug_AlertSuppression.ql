/**
 * @name Alert suppression
 * @description Analyzes and identifies alert suppression mechanisms in Python codebases, 
 *              providing detailed information about how warnings and alerts are being suppressed.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities for handling suppression logic
private import codeql.util.suppression.AlertSuppression as SuppressionUtils
// Import Python comment processing utilities for analyzing code comments
private import semmle.python.Comment as PyComment

// Represents enhanced AST nodes with comprehensive location tracking capabilities
class EnhancedAstNode instanceof PyComment::AstNode {
  // Check if node corresponds to specific file location coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Generate human-readable string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with precise location tracking and text extraction
class TrackedSingleLineComment instanceof PyComment::Comment {
  // Verify if comment matches specified location coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Extract the textual content from the comment
  string getText() { result = super.getContents() }

  // Provide descriptive string representation of the comment
  string toString() { result = super.toString() }
}

// Apply suppression relationship generation using SuppressionUtils template
import SuppressionUtils::Make<EnhancedAstNode, TrackedSingleLineComment>

/**
 * A noqa-style suppression comment. Both pylint and pyflakes respect this convention,
 * making it a standard mechanism for suppressing warnings in Python codebases.
 */
// Represents suppression comments following the noqa convention
class NoqaStyleSuppressionComment extends SuppressionComment instanceof TrackedSingleLineComment {
  // Constructor that identifies noqa comment patterns with case-insensitive matching
  NoqaStyleSuppressionComment() {
    TrackedSingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Return the standardized suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Define the scope of code coverage for this suppression annotation
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Ensure comment location matches and enforce line-start positioning
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}