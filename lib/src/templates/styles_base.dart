String baseStyles() => '''
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    min-height: 100vh;
    padding: 1rem 0;
}

.container {
    width: calc(100% - 40px);
    margin: 0 20px;
}

.header {
    background: white;
    border-radius: 16px;
    padding: 1.1rem;
    margin-bottom: 1rem;
    box-shadow: 0 16px 50px rgba(0, 0, 0, 0.28);
}

.header-top {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    flex-wrap: wrap;
    margin-bottom: 0.75rem;
}

.header h1 {
    font-size: 1.2rem;
    color: #2d3748;
    margin-bottom: 0;
    display: flex;
    align-items: center;
    gap: 0.6rem;
}

.header h1::before {
    content: '🧪';
    font-size: 1.5rem;
}

.header-timestamps {
    display: flex;
    align-items: center;
    gap: 0.4rem;
    margin-left: auto;
    justify-content: flex-end;
    flex-wrap: wrap;
}

.header-chip {
    background: rgba(236, 241, 248, 0.9);
    padding: 0.3rem 0.6rem;
    border-radius: 16px;
    font-size: 0.64rem;
    font-weight: 600;
    color: #2d3748;
    box-shadow: 0 6px 18px rgba(76, 81, 191, 0.1);
    display: inline-flex;
    align-items: center;
    gap: 0.28rem;
    letter-spacing: 0.35px;
    white-space: nowrap;
}

.header-chip .chip-label {
    font-size: 0.52rem;
    text-transform: uppercase;
    letter-spacing: 0.55px;
    color: #5a6b82;
}

.header-chip .chip-value {
    font-size: 0.7rem;
    color: #1a202c;
}

.stats {
    display: flex;
    flex-wrap: wrap;
    gap: 0.45rem;
    margin-top: 0.75rem;
}

.stat-card {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 0.4rem 0.75rem;
    border-radius: 999px;
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    box-shadow: 0 6px 16px rgba(0, 0, 0, 0.18);
    transition: transform 0.2s, box-shadow 0.2s;
    min-height: 2.1rem;
}

.stat-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 24px rgba(0, 0, 0, 0.22);
}

.stat-card.passed {
    background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
}

.stat-card.failed {
    background: linear-gradient(135deg, #ee0979 0%, #ff6a00 100%);
}

.stat-card.golden {
    background: linear-gradient(135deg, #f6d365 0%, #fda085 100%);
    color: #553c02;
}

.stat-card h3 {
    font-size: 0.95rem;
    font-weight: 700;
    margin: 0;
}

.stat-card p {
    font-size: 0.58rem;
    opacity: 0.9;
    text-transform: uppercase;
    letter-spacing: 0.85px;
    margin: 0;
}

.copy-button {
    border: none;
    background: rgba(76, 81, 191, 0.12);
    color: #4c51bf;
    width: 1.2rem;
    height: 1.2rem;
    border-radius: 999px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    font-size: 0.85rem;
    line-height: 1;
    transition: background 0.2s ease, transform 0.2s ease, color 0.2s ease;
}

.copy-button:hover {
    background: rgba(76, 81, 191, 0.22);
    transform: translateY(-1px);
}

.copy-button:focus {
    outline: none;
    box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.35);
}

.copy-button:active {
    transform: translateY(0);
}

.footer {
    margin-top: 2rem;
    text-align: center;
    color: white;
    opacity: 0.8;
    font-size: 0.8rem;
}

.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.9);
    justify-content: center;
    align-items: center;
}

.modal.active {
    display: flex;
}

.modal-content {
    max-width: 90%;
    max-height: 90%;
    object-fit: contain;
    border-radius: 10px;
}

.modal-close {
    position: absolute;
    top: 2rem;
    right: 2rem;
    color: white;
    font-size: 3rem;
    cursor: pointer;
    font-weight: bold;
    transition: transform 0.2s;
}

.modal-close:hover {
    transform: scale(1.2);
}

@media (max-width: 768px) {
    body {
        padding: 1rem;
    }

    .header-top {
        flex-direction: column;
        align-items: flex-start;
        gap: 0.5rem;
    }

    .header-timestamps {
        margin-left: 0;
        width: 100%;
        justify-content: flex-start;
    }

    .header h1 {
        font-size: 1.4rem;
    }

    .stat-card {
        width: 100%;
        justify-content: space-between;
    }

    .stat-card h3 {
        font-size: 1.05rem;
    }

    .screenshots-grid {
        grid-template-columns: 1fr;
    }
}
''';
