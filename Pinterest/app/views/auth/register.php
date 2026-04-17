<?php
declare(strict_types=1);
?>
<div class="auth-page-outer">
    <div class="row justify-content-center w-100">
        <div class="col-md-5 col-lg-4">
            <div class="card auth-page-card border-0 shadow-lg">
                <div class="card-body p-4 p-md-5">
                    <div class="auth-page-badge mb-4">
                        <span class="auth-page-badge-inner" aria-hidden="true">P</span>
                    </div>
                    <h1 class="auth-page-title h4 mb-2">Đăng ký</h1>
                    <p class="auth-page-lead text-muted mb-4">Tạo tài khoản miễn phí để lưu ghim và chia sẻ ý tưởng.</p>
                    <?php if (!empty($error)): ?>
                        <div class="alert alert-danger auth-page-alert"><?= htmlspecialchars($error) ?></div>
                    <?php endif; ?>
                    <form method="post" action="index.php?r=auth/register" class="auth-page-form">
                        <div class="form-group">
                            <label class="auth-page-label" for="auth-register-name">Họ tên</label>
                            <input id="auth-register-name" type="text" class="form-control auth-page-input" name="name" required autocomplete="name">
                        </div>
                        <div class="form-group">
                            <label class="auth-page-label" for="auth-register-email">Email</label>
                            <input id="auth-register-email" type="email" class="form-control auth-page-input" name="email" required autocomplete="email">
                        </div>
                        <div class="form-group">
                            <label class="auth-page-label" for="auth-register-password">Mật khẩu</label>
                            <input id="auth-register-password" type="password" class="form-control auth-page-input" name="password" minlength="8" required autocomplete="new-password">
                        </div>
                        <button class="btn auth-page-btn-submit btn-block btn-lg" type="submit">Tạo tài khoản</button>
                    </form>
                    <p class="auth-page-switch text-center text-muted small mt-4 mb-0">
                        Đã có tài khoản? <a href="index.php?r=auth/login">Đăng nhập</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
