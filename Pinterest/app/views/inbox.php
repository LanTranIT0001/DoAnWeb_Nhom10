<?php
declare(strict_types=1);

$activePeerName = '';
$activePeerAvatar = '';
foreach ($conversations as $conversation) {
    if ($activeConversationId === (int) $conversation['id']) {
        $activePeerName = (string) ($conversation['peer_name'] ?? '');
        $activePeerAvatar = trim((string) ($conversation['peer_avatar'] ?? ''));
        break;
    }
}

$linkifyMessage = static function (string $text): string {
    $pattern = '~(https?://[^\s<]+|index\.php\?r=pin/detail&id=\d+)~i';
    $parts = preg_split($pattern, $text, -1, PREG_SPLIT_DELIM_CAPTURE);
    if (!is_array($parts)) {
        return htmlspecialchars($text);
    }

    $html = '';
    foreach ($parts as $part) {
        if ($part === '') {
            continue;
        }
        if (preg_match($pattern, $part) === 1) {
            $href = $part;
            if (stripos($href, 'http://') !== 0 && stripos($href, 'https://') !== 0) {
                $href = $part;
            }
            $html .= '<a href="' . htmlspecialchars($href) . '" target="_blank" rel="noopener noreferrer">'
                . htmlspecialchars($part) . '</a>';
            continue;
        }
        $html .= nl2br(htmlspecialchars($part));
    }

    return $html;
};

$confirmDeleteConversation = "B\u{1EA1}n c\u{00F3} ch\u{1EAF}c mu\u{1ED1}n x\u{00F3}a cu\u{1ED9}c tr\u{00F2} chuy\u{1EC7}n n\u{00E0}y kh\u{00F4}ng?";
?>
<div class="row chat-row">
    <div class="col-lg-4 mb-3">
        <div class="chat-sidebar shadow-sm rounded">
            <div class="chat-sidebar-header p-3 border-bottom">
                <h2 class="h6 mb-2">Tin nh&#x1EAF;n</h2>
                <form method="post" action="index.php?r=message/start" class="chat-search-form">
                    <div class="input-group">
                        <input type="text" class="form-control search-input" name="peer_username" placeholder="Nh&#x1EAD;p t&#xEA;n ho&#x1EB7;c username" autocomplete="off" required>
                        <div class="input-group-append">
                            <button class="btn btn-dark" type="submit">T&#xEC;m</button>
                        </div>
                    </div>
                    <small class="text-muted d-block mt-2">Nh&#x1EAD;p t&#xEA;n hi&#x1EC3;n th&#x1ECB; ho&#x1EB7;c username &#x111;&#x1EC3; b&#x1EAF;t &#x111;&#x1EA7;u chat. V&#x1EDB;i 1 k&#xFD; t&#x1EF1; ch&#x1EC9; t&#xEC;m &#x111;&#xFA;ng t&#xEA;n/username.</small>
                </form>
            </div>

            <div class="chat-sidebar-body p-0">
                <div class="conversation-list">
                    <?php if (empty($conversations)): ?>
                        <div class="conversation-empty p-4 text-center text-muted">
                            Ch&#x1B0;a c&#xF3; cu&#x1ED9;c tr&#xF2; chuy&#x1EC7;n n&#xE0;o.
                        </div>
                    <?php else: ?>
                        <?php foreach ($conversations as $conversation): ?>
                            <?php $isActive = $activeConversationId === (int) $conversation['id']; ?>
                            <a class="conversation-item d-flex align-items-center px-3 py-3 <?= $isActive ? 'active' : '' ?>"
                               href="index.php?r=message/inbox&conversation_id=<?= (int) $conversation['id'] ?>">
                                <div class="conversation-avatar mr-3">
                                    <?= avatar_circle_inner_html($conversation['peer_avatar'] ?? null, (string) ($conversation['peer_name'] ?? '')) ?>
                                </div>
                                <div class="conversation-content flex-fill">
                                    <div class="conversation-name font-weight-bold mb-1"><?= htmlspecialchars($conversation['peer_name'] ?: "Ng\u{01B0}\u{1EDD}i d\u{00F9}ng") ?></div>
                                    <div class="conversation-snippet text-muted small text-truncate"><?= htmlspecialchars($conversation['last_message'] ?: "B\u{1EAF}t \u{0111}\u{1EA7}u tr\u{00F2} chuy\u{1EC7}n...") ?></div>
                                </div>
                                <?php if (($conversation['unread_count'] ?? 0) > 0): ?>
                                    <div class="unread-dot ml-2"></div>
                                <?php endif; ?>
                            </a>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>

    <div class="col-lg-8">
        <div class="chat-panel shadow-sm rounded">
            <?php if ($activeConversationId > 0): ?>
                <div class="chat-panel-header border-bottom px-3 py-3 d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center chat-panel-peer">
                        <div class="chat-panel-peer-avatar" aria-hidden="true">
                            <?= avatar_circle_inner_html($activePeerAvatar !== '' ? $activePeerAvatar : null, $activePeerName !== '' ? $activePeerName : 'U') ?>
                        </div>
                        <div>
                            <div class="chat-panel-peer-name"><?= htmlspecialchars($activePeerName ?: "Cu\u{1ED9}c tr\u{00F2} chuy\u{1EC7}n") ?></div>
                            <div class="chat-panel-peer-status">&#x110;ang ho&#x1EA1;t &#x111;&#x1ED9;ng</div>
                        </div>
                    </div>
                    <form method="post" action="index.php?r=message/delete" class="chat-delete-form" onsubmit="return confirm(<?= json_encode($confirmDeleteConversation, JSON_UNESCAPED_UNICODE) ?>);">
                        <input type="hidden" name="conversation_id" value="<?= (int) $activeConversationId ?>">
                        <button class="btn btn-sm chat-btn-delete" type="submit">X&#xF3;a cu&#x1ED9;c tr&#xF2; chuy&#x1EC7;n</button>
                    </form>
                </div>
                <div class="chat-panel-body">
                    <div class="message-list">
                        <?php if (empty($messages)): ?>
                            <div class="chat-empty-state text-center text-muted py-5">Ch&#x1B0;a c&#xF3; tin nh&#x1EAF;n. G&#x1EED;i tin nh&#x1EAF;n &#x111;&#x1EA7;u ti&#xEA;n nh&#xE9;!</div>
                        <?php else: ?>
                            <?php foreach ($messages as $msg): ?>
                                <?php $isSent = $msg['sender_id'] === $currentUserId; ?>
                                <div class="message-item <?= $isSent ? 'sent' : 'received' ?>">
                                    <?php if (!$isSent): ?>
                                        <div class="message-peer-avatar" aria-hidden="true"><?= avatar_circle_inner_html($msg['sender_avatar'] ?? null, (string) ($msg['sender_name'] ?? 'N')) ?></div>
                                    <?php endif; ?>
                                    <div class="message-item-inner">
                                    <?php if (!$isSent): ?>
                                        <div class="message-author"><?= htmlspecialchars($msg['sender_name']) ?></div>
                                    <?php endif; ?>
                                    <div class="message-bubble">
                                        <?php $messageContent = trim((string) ($msg['content'] ?? '')); ?>
                                        <?php $sharedLink = !empty($msg['shared_pin_id']) ? 'index.php?r=pin/detail&id=' . (int) $msg['shared_pin_id'] : ''; ?>
                                        <?php $shouldHideContent = $sharedLink !== ''; ?>
                                        <?php if ($messageContent !== '' && !$shouldHideContent): ?>
                                            <?= $linkifyMessage($messageContent) ?>
                                        <?php endif; ?>
                                        <?php if (!empty($msg['shared_pin_id'])): ?>
                                            <div class="shared-pin mt-2 small text-primary">
                                                <a href="<?= htmlspecialchars($sharedLink) ?>"><?= htmlspecialchars($sharedLink) ?></a>
                                            </div>
                                        <?php endif; ?>
                                    </div>
                                    </div>
                                </div>
                            <?php endforeach; ?>
                        <?php endif; ?>
                    </div>
                </div>
                <div class="chat-panel-footer border-top">
                    <form method="post" action="index.php?r=message/send" class="chat-composer-form">
                        <input type="hidden" name="conversation_id" value="<?= (int) $activeConversationId ?>">
                        <input class="form-control chat-composer-input" type="text" name="content" placeholder="Nh&#x1EAF;n tin..." autocomplete="off">
                        <button class="chat-composer-send" type="submit" aria-label="G&#x1EED;i tin nh&#x1EAF;n">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">
                                <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
                            </svg>
                        </button>
                    </form>
                </div>
            <?php else: ?>
                <div class="chat-empty-panel d-flex flex-column justify-content-center align-items-center text-center p-5">
                    <?php if (empty($conversations)): ?>
                        <div class="mb-3">
                            <strong>Ch&#x1B0;a c&#xF3; cu&#x1ED9;c tr&#xF2; chuy&#x1EC7;n n&#xE0;o</strong>
                        </div>
                        <div class="text-muted">Nh&#x1EAD;p t&#xEA;n ng&#x1B0;&#x1EDD;i d&#xF9;ng b&#xEA;n tr&#xE1;i &#x111;&#x1EC3; b&#x1EAF;t &#x111;&#x1EA7;u tr&#xF2; chuy&#x1EC7;n.</div>
                    <?php else: ?>
                        <div class="mb-3">
                            <strong>Ch&#x1ECD;n m&#x1ED9;t cu&#x1ED9;c tr&#xF2; chuy&#x1EC7;n</strong>
                        </div>
                    <?php endif; ?>
                </div>
            <?php endif; ?>
        </div>
    </div>
</div>
