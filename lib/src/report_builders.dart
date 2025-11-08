import 'package:self_testing/src/report_helpers.dart';

String buildScenarioCard(
  Map<String, dynamic> scenario, {
  required int index,
}) {
  final steps = extractSteps(scenario);
  final status = (scenario['status'] ?? 'unknown').toString();
  final scenarioName = (scenario['name'] ?? 'Scenario').toString();
  final scenarioId = 'scenario-$index';
  final scenarioCopyText = escapeAttribute(scenarioName);
  final passedSteps = steps.where((step) => step['status'] == 'passed').length;
  final failedSteps = steps.length - passedSteps;
  final durationValue = scenario['durationMs'];
  final durationMs = durationValue is num ? durationValue.toInt() : null;
  final formattedStart = formatDateTime(scenario['startedAt']?.toString());
  final formattedEnd = formatDateTime(scenario['endedAt']?.toString());
  final durationLabel = formatDuration(durationMs);
  final stepsMarkup = steps.isNotEmpty
      ? steps
          .asMap()
          .entries
          .map(
            (entry) => buildTestCard(
              entry.value,
              scenarioId: scenarioId,
              index: entry.key,
              nested: true,
            ),
          )
          .join('\n')
      : '<div class="no-screenshots">No steps recorded.</div>';

  final cardClasses = ['scenario-card', 'expandable', status].join(' ');

  return '''
      <div class="$cardClasses">
          <div class="scenario-header $status expandable-header" role="button" tabindex="0" aria-expanded="false">
              <div class="scenario-title">
                  <span class="scenario-toggle-icon" aria-hidden="true">&#9654;</span>
                  <span class="scenario-title-text">${escapeHtml(scenarioName)}</span>
                  <button class="copy-button" type="button" aria-label="Copy scenario title" data-copy="$scenarioCopyText">📋</button>
              </div>
              <div class="scenario-metrics">
                  <div class="scenario-chip-group">
                      <span class="scenario-chip total"><span class="chip-label">Steps</span><span class="chip-value">${steps.length}</span></span>
                      <span class="scenario-chip passed"><span class="chip-label">Passed</span><span class="chip-value">$passedSteps</span></span>
                      <span class="scenario-chip failed"><span class="chip-label">Failed</span><span class="chip-value">$failedSteps</span></span>
                  </div>
                  <div class="scenario-chip-group">
                      <span class="scenario-chip subtle"><span class="chip-label">Start</span><span class="chip-value">$formattedStart</span></span>
                      <span class="scenario-chip subtle"><span class="chip-label">End</span><span class="chip-value">$formattedEnd</span></span>
                      <span class="scenario-chip subtle"><span class="chip-label">Duration</span><span class="chip-value">$durationLabel</span></span>
                  </div>
              </div>
              <div class="scenario-status $status">${status.toUpperCase()}</div>
          </div>
          <div class="scenario-body">
              <div class="scenario-steps">
                  $stepsMarkup
              </div>
          </div>
      </div>
  ''';
}

String buildTestCard(
  Map<String, dynamic> result, {
  required String scenarioId,
  required int index,
  bool nested = false,
}) {
  final name = (result['name'] ?? 'Unknown Test').toString();
  final status = (result['status'] ?? 'unknown').toString();
  final timestamp = result['timestamp']?.toString() ?? '';
  final durationValue = result['durationMs'];
  final durationMs = durationValue is num ? durationValue.toInt() : null;
  final error = result['error'];
  final stepCopyText = escapeAttribute(name);

  final rawScreenshots = result['screenshots'];
  final screenshots = rawScreenshots is List
      ? rawScreenshots.map((value) => value.toString()).toList()
      : const <String>[];
  final goldenEntries = normalizeGoldenEntries(result['golden']);
  final rawDetails = result['details'];
  final details = rawDetails is List
      ? rawDetails
          .map((value) => value.toString())
          .where((value) => value.trim().isNotEmpty)
          .toList()
      : const <String>[];

  final errorCopyText = error != null
      ? escapeAttribute('Error Details\n${error.toString()}')
      : '';
  final detailsCopyText = details.isNotEmpty
      ? escapeAttribute(
          [
            'Verification Details',
            ...details.map((item) => '- $item'),
          ].join('\n'),
        )
      : '';

  final hasScreenshots = screenshots.isNotEmpty;
  final hasGolden = goldenEntries.isNotEmpty;
  final showScreenshots = hasScreenshots && !hasGolden;
  final isExpandable = showScreenshots || hasGolden;

  final finishedAt = timestamp.isNotEmpty ? formatDateTime(timestamp) : 'N/A';
  final durationLabel = formatDuration(durationMs);

  final errorSection = error != null
      ? '''
          <div class="error-section">
              <div class="error-title">
                  <span class="error-title-text">Error Details</span>
                  <button class="copy-button" type="button" aria-label="Copy error details" data-copy="$errorCopyText">📋</button>
              </div>
              <div class="error-message">${escapeHtml(error.toString())}</div>
          </div>
      '''
      : '';

  final screenshotsSection = showScreenshots
      ? '''
          <div class="screenshots-section">
              <div class="screenshots-title">Screenshots</div>
              <div class="screenshots-grid">
                  ${screenshots.map((screenshot) => '''
                      <div class="screenshot-item" onclick="openModal('screenshots/${escapeHtml(screenshot)}')">
                          <img src="screenshots/${escapeHtml(screenshot)}" alt="${escapeHtml(screenshot)}">
                          <div class="screenshot-label">${escapeHtml(screenshot)}</div>
                      </div>
                  ''').join('\n')}
              </div>
          </div>
      '''
      : '';

  final detailsSection = details.isNotEmpty
      ? '''
          <details class="details-section">
              <summary>
                  <span class="details-toggle-icon" aria-hidden="true">&#9654;</span>
                  <span class="details-summary">Verification Details</span>
                  <button class="copy-button" type="button" aria-label="Copy verification details" data-copy="$detailsCopyText">📋</button>
              </summary>
              <ul>
                  ${details.map((item) => '<li>${escapeHtml(item)}</li>').join('\n')}
              </ul>
          </details>
      '''
      : '';

  final goldenSection = buildGoldenSection(goldenEntries);
  final bodySections = [
    detailsSection,
    errorSection,
    screenshotsSection,
    goldenSection,
  ].where((section) => section.trim().isNotEmpty).join('\n');
  final bodyMarkup = bodySections.isEmpty
      ? ''
      : '''
          <div class="test-body">
              $bodySections
          </div>
      ''';
  final cardClasses = [
    'test-card',
    if (isExpandable) 'expandable',
    if (nested) 'nested',
  ].join(' ');

  final headerClasses = [
    'test-header',
    status,
    if (isExpandable) 'expandable-header',
  ].join(' ');

  final headerAttributes = isExpandable
      ? 'class="$headerClasses" role="button" tabindex="0" aria-expanded="false"'
      : 'class="$headerClasses"';

  final toggleIcon = isExpandable
      ? '<span class="test-toggle-icon" aria-hidden="true">&#9654;</span>'
      : '';

  final finishedChip =
      '<span class="scenario-chip subtle"><span class="chip-label">Finished</span><span class="chip-value">${escapeHtml(finishedAt)}</span></span>';
  final durationChip =
      '<span class="scenario-chip subtle"><span class="chip-label">Duration</span><span class="chip-value">${escapeHtml(durationLabel)}</span></span>';
  final metaSection = '<div class="test-meta">$finishedChip $durationChip</div>';

  return '''
      <div class="$cardClasses">
          <div $headerAttributes>
              <div class="test-name">$toggleIcon<span class="test-name-text">${escapeHtml(name)}</span><button class="copy-button" type="button" aria-label="Copy step title" data-copy="$stepCopyText">📋</button></div>
              $metaSection
              <div class="test-status $status">${status.toUpperCase()}</div>
          </div>
          $bodyMarkup
      </div>
  ''';
}

String buildGoldenSection(List<Map<String, dynamic>> entries) {
  if (entries.isEmpty) return '';
  final hasMultiple = entries.length > 1;
  final sections = <String>[];
  for (var index = 0; index < entries.length; index++) {
    final suffix = hasMultiple ? ' #${index + 1}' : '';
    sections.add(buildSingleGoldenSection(entries[index], suffix));
  }
  return sections.join('\n');
}

String buildSingleGoldenSection(
  Map<String, dynamic> golden,
  String titleSuffix,
) {
  if (golden.isEmpty) return '';

  final status = (golden['status'] ?? 'unknown').toString();
  final statusSlug = statusToSlug(status);
  final badgeClass = badgeClassForStatus(statusSlug);
  final statusLabel = formatGoldenStatus(status);
  final diffValue = (golden['diffPercentage'] as num?)?.toDouble();
  final toleranceValue = (golden['tolerance'] as num?)?.toDouble();
  final diffLabel = formatPercent(diffValue);
  final toleranceLabel = formatPercent(toleranceValue);
  final baselineCreated = golden['baselineCreated'] == true;
  final baselineUpdated = golden['baselineUpdated'] == true;
  final rawError = golden['error']?.toString();
  final friendlyError = buildGoldenErrorMessage(
    statusSlug,
    diffValue,
    toleranceValue,
    rawError,
  );

  final notes = <String>[];
  if (baselineCreated) {
    notes.add('A new golden baseline was captured during this run.');
  }
  if (baselineUpdated) {
    notes.add('The golden baseline was refreshed with the latest screenshot.');
  }

  final noteSection = notes.isNotEmpty
      ? '<div class="golden-note">${notes.join('<br>')}</div>'
      : '';

  final links = <String>[];
  final actualImage = golden['actualImage']?.toString();
  if (actualImage != null && actualImage.isNotEmpty) {
    links.add(
      '<a class="golden-link" href="$actualImage" target="_blank">Actual</a>',
    );
  }

  final goldenImage = golden['goldenImage']?.toString();
  if (goldenImage != null && goldenImage.isNotEmpty) {
    links.add(
      '<a class="golden-link" href="$goldenImage" target="_blank">Baseline</a>',
    );
  }

  final diffImage = golden['diffImage']?.toString();
  if (diffImage != null && diffImage.isNotEmpty) {
    links.add(
      '<a class="golden-link" href="$diffImage" target="_blank">Diff</a>',
    );
  }

  final linksSection =
      links.isNotEmpty ? '<div class="golden-links">${links.join('')}</div>' : '';

  final imagesSection = buildGoldenImages(golden);

  final errorSection = friendlyError != null
      ? '<div class="golden-error"><span class="golden-error-icon">⚠️</span><div class="golden-error-text">$friendlyError</div></div>'
      : '';

  return '''
      <div class="golden-section">
                      <div class="golden-header">
              <div class="golden-title">Golden Comparison$titleSuffix</div>
                              <div class="golden-badge $badgeClass">$statusLabel</div>
                      </div>
                      <div class="golden-metrics">
                              <div><span class="golden-label">Difference:</span> $diffLabel</div>
                              <div><span class="golden-label">Tolerance:</span> $toleranceLabel</div>
                      </div>
                      $imagesSection
                      $noteSection
                      $linksSection
                      $errorSection
              </div>
      ''';
}

String buildGoldenImages(Map<String, dynamic> golden) {
  final cards = <String>[];

  final actualImage = golden['actualImage']?.toString();
  if (actualImage != null && actualImage.isNotEmpty) {
    cards.add(goldenImageCard('Actual', actualImage));
  }

  final baselineImage = golden['goldenImage']?.toString();
  if (baselineImage != null && baselineImage.isNotEmpty) {
    cards.add(goldenImageCard('Baseline', baselineImage));
  }

  final diffImage = golden['diffImage']?.toString();
  if (diffImage != null && diffImage.isNotEmpty) {
    cards.add(goldenImageCard('Diff', diffImage));
  } else {
    final statusSlug = statusToSlug((golden['status'] ?? '').toString());
    final message =
        statusSlug == 'baselinecreated' || statusSlug == 'baselineupdated'
            ? 'Diff image will be generated after the next comparison run.'
            : 'Diff image not available.';
    cards.add(goldenImagePlaceholder('Diff', message));
  }

  if (cards.isEmpty) return '';

  return '''
      <div class="golden-images">
          ${cards.join('\n')}
      </div>
  ''';
}

String goldenImageCard(String label, String imagePath) {
  final safeLabel = escapeHtml(label);
  final safeImagePath = escapeHtml(imagePath);
  return '''
      <div class="golden-image-card" onclick="openModal('$safeImagePath')">
          <img src="$safeImagePath" alt="$safeLabel image">
          <div class="golden-image-label">$safeLabel</div>
      </div>
  ''';
}

String goldenImagePlaceholder(String label, String message) {
  final safeLabel = escapeHtml(label);
  final safeMessage = escapeHtml(message);
  return '''
      <div class="golden-image-card placeholder">
          <div class="golden-image-placeholder">$safeMessage</div>
          <div class="golden-image-label">$safeLabel</div>
      </div>
  ''';
}

String? buildGoldenErrorMessage(
  String statusSlug,
  double? diffValue,
  double? toleranceValue,
  String? rawError,
) {
  if (statusSlug == 'mismatch') return null;

  if (statusSlug == 'error') {
    if (rawError == null || rawError.isEmpty) {
      return escapeHtml(
        'Golden comparison failed because an unexpected error occurred.',
      );
    }

    final cleaned = rawError.replaceFirst(
      RegExp(r'^Golden comparison for [^:]+ failed: '),
      '',
    );
    return escapeHtml(cleaned);
  }

  return null;
}
