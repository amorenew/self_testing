String scenarioStyles() => '''
.scenario-list {
    display: grid;
    gap: 1.15rem;
}

.scenario-card {
    background: white;
    border-radius: 18px;
    overflow: hidden;
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    transition: transform 0.3s, box-shadow 0.3s;
    border-left: 6px solid #4c51bf;
}

.scenario-card:hover {
    transform: translateY(-10px);
    box-shadow: 0 30px 80px rgba(0, 0, 0, 0.4);
}

.scenario-card.passed {
    border-left-color: #38ef7d;
}

.scenario-card.failed {
    border-left-color: #ff6a00;
}

.scenario-card.expandable .scenario-body {
    display: none;
}

.scenario-card.expandable.open .scenario-body {
    display: block;
}

.scenario-header {
    padding: 0.72rem 1rem;
    display: flex;
    align-items: center;
    gap: 0.55rem;
    border-bottom: 2px solid #e2e8f0;
    flex-wrap: wrap;
    justify-content: flex-start;
}

.scenario-header.passed {
    background: linear-gradient(135deg, rgba(17, 153, 142, 0.12) 0%, rgba(56, 239, 125, 0.12) 100%);
}

.scenario-header.failed {
    background: linear-gradient(135deg, rgba(238, 9, 121, 0.12) 0%, rgba(255, 106, 0, 0.12) 100%);
}

.scenario-header.expandable-header {
    cursor: pointer;
    user-select: none;
}

.scenario-header.expandable-header:focus {
    outline: none;
}

.scenario-header.expandable-header:focus-visible {
    box-shadow: inset 0 0 0 2px rgba(102, 126, 234, 0.28);
}

.scenario-title {
    display: inline-flex;
    align-items: center;
    gap: 0.4rem;
    font-size: 1.05rem;
    font-weight: 600;
    color: #1a202c;
    flex: 0 1 auto;
}

.scenario-title .copy-button {
    margin-left: 0.35rem;
    flex: 0 0 auto;
}

.scenario-title-text {
    flex: 0 1 auto;
    min-width: 0;
}

.scenario-toggle-icon {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 1.3rem;
    height: 1.3rem;
    color: #4c51bf;
    font-size: 0.85rem;
    transition: transform 0.2s ease;
}

.scenario-card.expandable.open .scenario-toggle-icon {
    transform: rotate(90deg);
}

.scenario-metrics {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 0.5rem;
    flex-wrap: wrap;
    margin-left: auto;
}

.scenario-chip-group {
    display: flex;
    align-items: center;
    justify-content: flex-end;
    gap: 0.35rem;
    flex-wrap: wrap;
}

.scenario-chip {
    background: rgba(255, 255, 255, 0.9);
    padding: 0.16rem 0.32rem;
    border-radius: 16px;
    font-size: 0.64rem;
    font-weight: 600;
    color: #2d3748;
    box-shadow: 0 6px 18px rgba(76, 81, 191, 0.12);
    display: inline-flex;
    align-items: center;
    gap: 0.15rem;
    letter-spacing: 0.4px;
    min-width: 4.2rem;
    justify-content: space-between;
}

.scenario-chip .chip-label {
    font-size: 0.52rem;
    text-transform: uppercase;
    letter-spacing: 0.55px;
    color: #5a6b82;
}

.scenario-chip .chip-value {
    font-size: 0.72rem;
    color: #1a202c;
}

.scenario-chip.total {
    background: rgba(102, 126, 234, 0.16);
    color: #3c3fa3;
}

.scenario-chip.passed {
    background: rgba(56, 239, 125, 0.18);
    color: #067a4d;
}

.scenario-chip.failed {
    background: rgba(255, 107, 107, 0.2);
    color: #c53030;
}

.scenario-chip.subtle {
    background: rgba(236, 241, 248, 0.8);
    color: #4a5568;
    box-shadow: none;
}

.scenario-status {
    display: inline-flex;
    align-items: center;
    gap: 0.3rem;
    padding: 0.18rem 0.4rem;
    border-radius: 16px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.8px;
    font-size: 0.62rem;
    margin-left: 0.4rem;
    min-width: 4.5rem;
    justify-content: center;
}

.scenario-status.passed {
    background: rgba(56, 239, 125, 0.24);
    color: #067a4d;
}

.scenario-status.failed {
    background: rgba(255, 107, 107, 0.26);
    color: #c24024;
}

.scenario-status::before {
    font-size: 0.85rem;
}

.scenario-status.passed::before {
    content: '✅';
}

.scenario-status.failed::before {
    content: '❌';
}

.scenario-body {
    padding: 1.25rem;
    background: #f8fafc;
}

.scenario-steps {
    display: grid;
    gap: 1rem;
}
''';
