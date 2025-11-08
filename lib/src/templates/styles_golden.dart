String goldenStyles() => '''
.screenshots-section {
    margin-top: 1.1rem;
}

.screenshots-title {
    font-size: 0.9rem;
    font-weight: 600;
    color: #2d3748;
    margin-bottom: 0.75rem;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.screenshots-title::before {
    content: '📸';
}

.screenshots-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 0.75rem;
}

.screenshot-item {
    position: relative;
    border-radius: 15px;
    overflow: hidden;
    box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
    transition: transform 0.3s;
    cursor: pointer;
}

.screenshot-item:hover {
    transform: scale(1.05);
}

.screenshot-item img {
    width: 100%;
    height: auto;
    display: block;
    transition: transform 0.3s;
}

.screenshot-item:hover img {
    transform: scale(1.1);
}

.screenshot-label {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    background: rgba(0, 0, 0, 0.7);
    color: white;
    padding: 0.6rem;
    font-size: 0.8rem;
    text-align: center;
    backdrop-filter: blur(10px);
}

.no-screenshots {
    color: #a0aec0;
    font-style: italic;
    text-align: center;
    padding: 1.5rem;
    background: #f7fafc;
    border-radius: 10px;
}

.golden-section {
    margin-top: 1.1rem;
    background: #f8fafc;
    border-radius: 15px;
    padding: 1rem 1.25rem;
    border: 1px solid #e2e8f0;
    box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.6);
}

.golden-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 1rem;
    margin-bottom: 0.6rem;
}

.golden-title {
    font-size: 0.9rem;
    font-weight: 600;
    color: #2d3748;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.golden-title::before {
    content: '🎯';
}

.golden-badge {
    display: inline-flex;
    align-items: center;
    padding: 0.35rem 0.85rem;
    border-radius: 999px;
    font-size: 0.65rem;
    text-transform: uppercase;
    letter-spacing: 1px;
    font-weight: 700;
}

.golden-match {
    background: rgba(56, 239, 125, 0.18);
    color: #0c7c4f;
    border: 1px solid rgba(56, 239, 125, 0.4);
}

.golden-mismatch {
    background: rgba(255, 106, 0, 0.2);
    color: #b43403;
    border: 1px solid rgba(255, 106, 0, 0.4);
}

.golden-baselinecreated,
.golden-baselineupdated {
    background: rgba(102, 126, 234, 0.2);
    color: #364fc7;
    border: 1px solid rgba(102, 126, 234, 0.4);
}

.golden-error-badge {
    background: rgba(254, 178, 178, 0.3);
    color: #c53030;
    border: 1px solid rgba(254, 178, 178, 0.6);
}

.golden-metrics {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 0.4rem;
    margin-bottom: 0.6rem;
    font-size: 0.8rem;
    color: #2d3748;
}

.golden-label {
    font-weight: 600;
    margin-right: 0.2rem;
    color: #4a5568;
}

.golden-links {
    display: flex;
    gap: 0.6rem;
    flex-wrap: wrap;
    margin-top: 0.6rem;
}

.golden-link {
    padding: 0.45rem 0.75rem;
    border-radius: 999px;
    background: #edf2f7;
    color: #2d3748;
    font-weight: 600;
    text-decoration: none;
    transition: background 0.2s, transform 0.2s;
}

.golden-link:hover {
    background: #e2e8f0;
    transform: translateY(-2px);
}

.golden-note {
    margin-top: 0.5rem;
    color: #1f2933;
    font-size: 0.78rem;
    line-height: 1.35;
    background: linear-gradient(120deg, rgba(102, 126, 234, 0.18), rgba(118, 75, 162, 0.08));
    border-radius: 12px;
    padding: 0.75rem 0.85rem;
    border: 1px solid rgba(102, 126, 234, 0.2);
}

.golden-error {
    margin-top: 0.75rem;
    display: flex;
    align-items: flex-start;
    gap: 0.75rem;
    color: #822727;
    font-size: 0.8rem;
    line-height: 1.35;
    background: linear-gradient(120deg, rgba(254, 178, 178, 0.35), rgba(254, 215, 215, 0.25));
    border: 1px solid rgba(229, 62, 62, 0.3);
    border-radius: 12px;
    padding: 0.75rem 0.95rem;
    box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.35);
}

.golden-error-icon {
    font-size: 1.25rem;
    line-height: 1;
    margin-top: 0.15rem;
}

.golden-error-text {
    flex: 1;
}

.golden-images {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
    gap: 0.75rem;
    margin-top: 0.75rem;
}

.golden-image-card {
    position: relative;
    border-radius: 14px;
    overflow: hidden;
    box-shadow: 0 12px 30px rgba(0, 0, 0, 0.18);
    background: white;
    display: flex;
    flex-direction: column;
    cursor: pointer;
    transition: transform 0.25s, box-shadow 0.25s;
}

.golden-image-card:hover {
    transform: translateY(-6px);
    box-shadow: 0 18px 40px rgba(0, 0, 0, 0.25);
}

.golden-image-card img {
    width: 100%;
    height: auto;
    display: block;
    object-fit: contain;
    background: #1a202c;
}

.golden-image-label {
    padding: 0.6rem 0.85rem;
    font-weight: 600;
    color: #2d3748;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.golden-image-label::before {
    content: '🖼️';
}

.golden-image-card.placeholder,
.golden-image-card.missing {
    cursor: default;
    align-items: center;
    justify-content: center;
    padding: 1.5rem 1.25rem;
    background: #edf2f7;
    border: 2px dashed #cbd5e0;
}

.golden-image-card.placeholder:hover,
.golden-image-card.missing:hover {
    transform: none;
    box-shadow: 0 12px 30px rgba(0, 0, 0, 0.18);
}

.golden-image-placeholder {
    text-align: center;
    color: #4a5568;
    font-weight: 600;
}
''';
