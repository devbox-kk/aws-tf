// DOM要素の取得
const ctaButton = document.getElementById('cta-button');
const contactForm = document.getElementById('contact-form');
const navLinks = document.querySelectorAll('.nav-links a');

// ページ読み込み時の初期化
document.addEventListener('DOMContentLoaded', function() {
    // ローディングアニメーション
    document.body.classList.add('loading');
    
    // スムーズスクロールの設定
    setupSmoothScroll();
    
    // CTA ボタンのクリックイベント
    setupCTAButton();
    
    // フォームの送信イベント
    setupContactForm();
    
    // ナビゲーションのアクティブ状態管理
    setupNavigation();
    
    // スクロール時のアニメーション
    setupScrollAnimations();
});

// スムーズスクロール設定
function setupSmoothScroll() {
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
}

// CTA ボタンの設定
function setupCTAButton() {
    ctaButton.addEventListener('click', function() {
        // ボタンクリック時のアニメーション
        this.style.transform = 'scale(0.95)';
        setTimeout(() => {
            this.style.transform = 'scale(1)';
        }, 150);
        
        // お問い合わせセクションにスクロール
        document.getElementById('contact').scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
        
        // ウェルカムメッセージの表示
        showNotification('お問い合わせセクションをご覧ください！', 'success');
    });
}

// お問い合わせフォームの設定
function setupContactForm() {
    contactForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        // フォームデータの取得
        const formData = new FormData(this);
        const name = formData.get('name');
        const email = formData.get('email');
        const message = formData.get('message');
        
        // 簡単なバリデーション
        if (!name || !email || !message) {
            showNotification('すべての項目を入力してください。', 'error');
            return;
        }
        
        if (!isValidEmail(email)) {
            showNotification('有効なメールアドレスを入力してください。', 'error');
            return;
        }
        
        // 送信処理（実際の送信処理はここに実装）
        simulateFormSubmission(name, email, message);
    });
}

// メールアドレスの妥当性チェック
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

// フォーム送信のシミュレーション
function simulateFormSubmission(name, email, message) {
    // 送信中の表示
    const submitButton = contactForm.querySelector('button[type="submit"]');
    const originalText = submitButton.textContent;
    submitButton.textContent = '送信中...';
    submitButton.disabled = true;
    
    // 送信処理のシミュレーション（3秒後に完了）
    setTimeout(() => {
        submitButton.textContent = originalText;
        submitButton.disabled = false;
        
        // フォームのリセット
        contactForm.reset();
        
        // 成功メッセージの表示
        showNotification(`${name}様、お問い合わせありがとうございます！`, 'success');
        
        // コンソールにログ出力（実際の送信処理では削除）
        console.log('Form submitted:', { name, email, message });
    }, 3000);
}

// ナビゲーションの設定
function setupNavigation() {
    // スクロール時のナビゲーションアクティブ状態更新
    window.addEventListener('scroll', updateActiveNav);
    
    // ハンバーガーメニューの設定（モバイル対応）
    const hamburger = document.querySelector('.hamburger');
    const navLinksContainer = document.querySelector('.nav-links');
    
    if (hamburger) {
        hamburger.addEventListener('click', function() {
            navLinksContainer.classList.toggle('active');
        });
    }
}

// アクティブなナビゲーションの更新
function updateActiveNav() {
    const sections = document.querySelectorAll('section');
    const navLinks = document.querySelectorAll('.nav-links a');
    
    let currentSection = '';
    
    sections.forEach(section => {
        const sectionTop = section.offsetTop - 100;
        const sectionHeight = section.offsetHeight;
        
        if (window.scrollY >= sectionTop && window.scrollY < sectionTop + sectionHeight) {
            currentSection = section.id;
        }
    });
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href').substring(1) === currentSection) {
            link.classList.add('active');
        }
    });
}

// スクロールアニメーションの設定
function setupScrollAnimations() {
    // Intersection Observer を使用した要素の表示アニメーション
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
            }
        });
    }, observerOptions);
    
    // アニメーション対象の要素を監視
    const animateElements = document.querySelectorAll('.feature, .service-card, .form-group');
    animateElements.forEach(element => {
        observer.observe(element);
    });
}

// 通知メッセージの表示
function showNotification(message, type = 'info') {
    // 既存の通知を削除
    const existingNotification = document.querySelector('.notification');
    if (existingNotification) {
        existingNotification.remove();
    }
    
    // 新しい通知を作成
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.textContent = message;
    
    // スタイルを設定
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 20px;
        border-radius: 5px;
        color: white;
        font-weight: bold;
        z-index: 10000;
        animation: slideInRight 0.5s ease-out;
    `;
    
    // タイプに応じた背景色を設定
    switch (type) {
        case 'success':
            notification.style.backgroundColor = '#27ae60';
            break;
        case 'error':
            notification.style.backgroundColor = '#e74c3c';
            break;
        case 'warning':
            notification.style.backgroundColor = '#f39c12';
            break;
        default:
            notification.style.backgroundColor = '#3498db';
    }
    
    // ページに追加
    document.body.appendChild(notification);
    
    // 3秒後に自動削除
    setTimeout(() => {
        notification.style.animation = 'slideOutRight 0.5s ease-out forwards';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 500);
    }, 3000);
}

// アニメーションのCSS定義
const animationStyles = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    
    .animate-in {
        animation: fadeInUp 0.8s ease-out forwards;
    }
    
    .nav-links a.active {
        color: #3498db;
        position: relative;
    }
    
    .nav-links a.active::after {
        content: '';
        position: absolute;
        bottom: -5px;
        left: 0;
        width: 100%;
        height: 2px;
        background-color: #3498db;
    }
`;

// アニメーションスタイルをページに追加
const styleSheet = document.createElement('style');
styleSheet.textContent = animationStyles;
document.head.appendChild(styleSheet);

// ページの離脱時にローカルストレージにデータを保存
window.addEventListener('beforeunload', function() {
    const formData = {
        name: document.getElementById('name').value,
        email: document.getElementById('email').value,
        message: document.getElementById('message').value
    };
    
    if (formData.name || formData.email || formData.message) {
        localStorage.setItem('contactFormData', JSON.stringify(formData));
    }
});

// ページ読み込み時にローカルストレージからデータを復元
window.addEventListener('load', function() {
    const savedData = localStorage.getItem('contactFormData');
    if (savedData) {
        const formData = JSON.parse(savedData);
        document.getElementById('name').value = formData.name || '';
        document.getElementById('email').value = formData.email || '';
        document.getElementById('message').value = formData.message || '';
        
        // 復元後にローカルストレージから削除
        localStorage.removeItem('contactFormData');
    }
});
