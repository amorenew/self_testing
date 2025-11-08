String reportScripts() => '''
function openModal(src) {
    const modal = document.getElementById('screenshotModal');
    const modalImg = document.getElementById('modalImage');
    modal.classList.add('active');
    modalImg.src = src;
}

function closeModal() {
    const modal = document.getElementById('screenshotModal');
    modal.classList.remove('active');
}

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeModal();
    }
});

function fallbackCopy(text, onSuccess, onFailure) {
    try {
        const textarea = document.createElement('textarea');
        textarea.value = text;
        textarea.style.position = 'fixed';
        textarea.style.opacity = '0';
        document.body.appendChild(textarea);
        textarea.focus();
        textarea.select();
        const successful = document.execCommand('copy');
        document.body.removeChild(textarea);
        if (successful) {
            onSuccess();
        } else {
            onFailure();
        }
    } catch (error) {
        onFailure();
    }
}

function setupCopyButtons() {
    document.querySelectorAll('.copy-button').forEach(function(button) {
        button.addEventListener('click', function(event) {
            event.preventDefault();
            event.stopPropagation();

            const targetId = button.getAttribute('data-copy-target');
            let text = '';

            if (targetId) {
                const targetElement = document.getElementById(targetId);
                if (targetElement) {
                    text = targetElement.textContent || '';
                }
            } else {
                text = button.getAttribute('data-copy') || '';
            }

            if (!text) {
                return;
            }

            const originalIcon = button.getAttribute('data-icon') || button.innerHTML;
            const originalLabel = button.getAttribute('data-original-label') || button.getAttribute('aria-label') || 'Copy to clipboard';
            button.setAttribute('data-icon', originalIcon);
            button.setAttribute('data-original-label', originalLabel);

            const markSuccess = function() {
                button.innerHTML = '✅';
                button.setAttribute('aria-label', 'Copied to clipboard');
                setTimeout(function() {
                    button.innerHTML = originalIcon;
                    button.setAttribute('aria-label', originalLabel);
                }, 2000);
            };

            const markFailure = function() {
                button.innerHTML = '⚠️';
                button.setAttribute('aria-label', 'Copy failed');
                setTimeout(function() {
                    button.innerHTML = originalIcon;
                    button.setAttribute('aria-label', originalLabel);
                }, 2000);
            };

            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(text).then(markSuccess).catch(function() {
                    fallbackCopy(text, markSuccess, markFailure);
                });
            } else {
                fallbackCopy(text, markSuccess, markFailure);
            }
        });
    });
}

document.querySelectorAll('.expandable-header').forEach(function(header) {
    const card = header.parentElement;

    const toggleCard = function() {
        const isOpen = card.classList.toggle('open');
        header.setAttribute('aria-expanded', isOpen ? 'true' : 'false');

        card.querySelectorAll('.test-body, .scenario-body').forEach(function(body) {
            if (isOpen) {
                body.classList.add('visible');
            } else {
                body.classList.remove('visible');
            }
        });

        const status = header.querySelector('.test-status, .scenario-status');
        if (status) {
            status.setAttribute('aria-hidden', (!isOpen).toString());
        }
    };

    header.addEventListener('click', function() {
        toggleCard();
    });

    header.addEventListener('keydown', function(event) {
        if (event.key === 'Enter' || event.key === ' ') {
            event.preventDefault();
            toggleCard();
        }
    });
});

document.querySelectorAll('.test-card.expandable, .scenario-card.expandable').forEach(function(card) {
    const hasGoldenMismatch = card.querySelector('.golden-mismatch');
    if (hasGoldenMismatch) {
        card.classList.add('open');
        const header = card.querySelector('.expandable-header');
        if (header) {
            header.setAttribute('aria-expanded', 'true');
        }
        card.querySelectorAll('.test-body, .scenario-body').forEach(function(body) {
            body.classList.add('visible');
        });
    }
});

setupCopyButtons();
''';
