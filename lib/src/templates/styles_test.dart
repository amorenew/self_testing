String testStyles() => '''
.test-card {
    background: white;
    border-radius: 18px;
    overflow: hidden;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    transition: transform 0.3s, box-shadow 0.3s;
}

.test-card:hover {
    transform: translateY(-10px);
    box-shadow: 0 30px 80px rgba(0, 0, 0, 0.4);
}

.test-card.expandable .test-body {
    display: none;
}

.test-card.expandable.open .test-body {
    display: block;
}

.test-card.nested {
    border-radius: 16px;
    box-shadow: none;
    border: 1px solid #e2e8f0;
    background: white;
}

.test-card.nested:hover {
    transform: none;
    box-shadow: none;
}

.test-card.nested .test-header {
    border-left-width: 3px;
    padding: 0.65rem 0.95rem;
}

.test-card.nested .test-body {
    padding: 0.9rem 1.1rem;
}

.test-card.expandable.open .test-toggle-icon {
    transform: rotate(90deg);
}

.test-header {
    padding: 0.55rem 0.9rem;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    gap: 0.6rem;
    flex-wrap: wrap;
    border-bottom: 2px solid #e2e8f0;
}

.test-header.passed {
    background: linear-gradient(135deg, rgba(17, 153, 142, 0.1) 0%, rgba(56, 239, 125, 0.1) 100%);
    border-left: 5px solid #38ef7d;
}

.test-header.failed {
    background: linear-gradient(135deg, rgba(238, 9, 121, 0.1) 0%, rgba(255, 106, 0, 0.1) 100%);
    border-left: 5px solid #ff6a00;
}

.test-header.expandable-header {
    cursor: pointer;
    user-select: none;
}

.test-header.expandable-header:focus {
    outline: none;
}

.test-header.expandable-header:focus-visible {
    box-shadow: inset 0 0 0 2px rgba(102, 126, 234, 0.28);
}

.test-name {
    font-size: 0.95rem;
    font-weight: 600;
    color: #2d3748;
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    flex: 1 1 auto;
    min-width: 0;
}

.test-name .copy-button {
    margin-left: 0.35rem;
    flex: 0 0 auto;
}

.test-name-text {
    flex: 0 1 auto;
    min-width: 0;
}

.test-toggle-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 1.1rem;
    height: 1.1rem;
    color: #4c51bf;
    font-size: 0.8rem;
    line-height: 1;
    transition: transform 0.2s ease;
}

.test-meta {
    display: flex;
    align-items: center;
    gap: 0.35rem;
    flex-wrap: wrap;
    margin-left: auto;
}

.test-status {
    display: inline-flex;
    align-items: center;
    gap: 0.35rem;
    padding: 0.28rem 0.62rem;
    border-radius: 16px;
    font-weight: 600;
    font-size: 0.64rem;
    text-transform: uppercase;
    letter-spacing: 0.55px;
    margin-left: 0.4rem;
}

.test-status.passed {
    background: rgba(56, 239, 125, 0.18);
    color: #0a7a4f;
}

.test-status.failed {
    background: rgba(255, 107, 107, 0.2);
    color: #c53030;
}

.test-status::before {
    font-size: 0.75rem;
}

.test-status.passed::before {
    content: '✅';
}

.test-status.failed::before {
    content: '❌';
}

.test-body {
    padding: 0.95rem 1rem;
}

.error-section {
    background: #fff5f5;
    border: 2px solid #fc8181;
    border-radius: 10px;
    padding: 1rem;
    margin-top: 1rem;
}

.error-title {
    color: #c53030;
    font-weight: 600;
    margin-bottom: 0.4rem;
    display: flex;
    align-items: center;
    gap: 0.5rem;
    justify-content: flex-start;
}

.error-title::before {
    content: '⚠️';
}

.error-title .copy-button {
    margin-left: 0.35rem;
    flex: 0 0 auto;
}

.error-title-text {
    flex: 0 1 auto;
    min-width: 0;
}

.error-message {
    color: #742a2a;
    font-family: 'Courier New', monospace;
    font-size: 0.9rem;
    white-space: pre-wrap;
    word-break: break-word;
}

.details-section {
    margin-top: 1rem;
    background: #edf2f7;
    border-radius: 12px;
    border: 1px solid #e2e8f0;
    overflow: hidden;
}

.details-section summary {
    list-style: none;
    cursor: pointer;
    padding: 0.75rem 1rem;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    gap: 0.45rem;
}

.details-section summary::-webkit-details-marker {
    display: none;
}

.details-section summary .copy-button {
    margin-left: 0.35rem;
    flex: 0 0 auto;
}

.details-toggle-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 1.1rem;
    height: 1.1rem;
    color: #4c51bf;
    font-size: 0.8rem;
    line-height: 1;
    transition: transform 0.2s ease;
}

.details-section[open] .details-toggle-icon {
    transform: rotate(90deg);
}

.details-summary {
    display: inline-flex;
    align-items: center;
    gap: 0.55rem;
    font-size: 0.9rem;
    font-weight: 600;
    color: #2d3748;
}

.details-summary::before {
    content: '📝';
}

.details-section[open] summary {
    border-bottom: 1px solid #cbd5e0;
    background: rgba(148, 163, 184, 0.15);
}

.details-section ul {
    list-style: disc;
    margin: 0;
    padding: 0.85rem 1.2rem 1.1rem 2.2rem;
    color: #4a5568;
    display: grid;
    gap: 0.35rem;
}
''';
