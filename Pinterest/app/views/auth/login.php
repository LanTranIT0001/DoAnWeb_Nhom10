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
                    <h1 class="auth-page-title h4 mb-2">Đăng nhập</h1>
                    <p class="auth-page-lead text-muted mb-4">Chào mừng bạn quay lại. Đăng nhập để tiếp tục khám phá ý tưởng.</p>
                    <?php if (!empty($_GET['msg']) && $_GET['msg'] === 'registered'): ?>
                        <div class="alert alert-success auth-page-alert">Đăng ký thành công, mời bạn đăng nhập.</div>
                    <?php endif; ?>
                    <?php if (!empty($error)): ?>
                        <div class="alert alert-danger auth-page-alert"><?= htmlspecialchars($error) ?></div>
                    <?php endif; ?>
                    <form method="post" action="index.php?r=auth/login" class="auth-page-form">
                        <div class="form-group">
                            <label class="auth-page-label" for="auth-login-email">Email</label>
                            <input id="auth-login-email" type="email" class="form-control auth-page-input" name="email" required autocomplete="email">
                        </div>
                        <div class="form-group">
                            <label class="auth-page-label" for="auth-login-password">Mật khẩu</label>
                            <input id="auth-login-password" type="password" class="form-control auth-page-input" name="password" required autocomplete="current-password">
                        </div>
                        <button class="btn auth-page-btn-submit btn-block btn-lg" type="submit">Đăng nhập</button>
                    </form>
                    <p class="auth-page-switch text-center text-muted small mt-4 mb-0">
                        Chưa có tài khoản? <a href="index.php?r=auth/register">Đăng ký</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>
