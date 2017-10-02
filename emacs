(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  '(indent-tabs-mode nil)
  '(tab-always-indent (quote always))
  '(tab-stop-list nil))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  )

(global-set-key "\C-h" 'delete-backward-char)
(setq scroll-step 1)

(defun my-c-mode-hook ()
  (c-set-style "linux")
  (setq tab-width 4)
  (setq c-basic-offset tab-width)
  (setq c-auto-newline nil)
  (setq c-tab-always-indent nil)
  )

(defun my-c-common-mode ()
  (c-toggle-hungry-state 1))
(add-hook 'c-mode-common-hook 'my-c-common-mode)


(add-hook 'c-mode-hook 'my-c-mode-hook)
(add-hook 'c++-mode-hook 'my-c-mode-hook)

;;;====================================
;;;; print - 印刷設定
;;;====================================
;;; Postscript で印刷
(setq my-print-command-format "paps --font=\"Monospace 7\" | lpr")
(defun my-print-region (begin end)
  (interactive "r")
  (shell-command-on-region begin end my-print-command-format))
(defun my-print-buffer ()
  (interactive)
  (my-print-region (point-min) (point-max)))


;;(cua-mode t)
;;(setq cua-enable-cua-keys nil)

(cua-mode t)
(setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
(transient-mark-mode 1) ;; No region when it is not highlighted
(setq cua-keep-region-after-copy t) ;; Standard Windows behaviour


;対応する確固の強調
(show-paren-mode 1)

;テーマカラー
;(require 'color-theme)
;(color-theme-initialize)
;(color-theme-arjen)
(load-theme 'deeper-blue t)

;エスケープシーケンスを処理
(autoload 'ansi-color-for-comint-mode-on "ansi-color"
		  "Set `ansi-color-for-comint-mode' to t." t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)


;;汎用機の SPF (mule みたいなやつ) には
;;画面を 2 分割したときの 上下を入れ替える swap screen
;;というのが PF 何番かにわりあてられていました。
(defun swap-screen()
  "Swap two screen,leaving cursor at current window."
  (interactive)
  (let ((thiswin (selected-window))
		(nextbuf (window-buffer (next-window))))
	(set-window-buffer (next-window) (window-buffer))
	(set-window-buffer thiswin nextbuf)))
(defun swap-screen-with-cursor()
  "Swap two screen,with cursor in same buffer."
  (interactive)
  (let ((thiswin (selected-window))
		(thisbuf (window-buffer)))
	(other-window 1)
	(set-window-buffer thiswin (window-buffer))
	(set-window-buffer (selected-window) thisbuf)))


(global-set-key [f2] 'swap-screen)
(global-set-key [S-f2] 'swap-screen-with-cursor)

;;;====================================
;;;; Buffer 設定
;;;===================================
;;; iswitchb は、バッファ名の一部の文字を入力することで
;;; 選択バッファの絞り込みを行う機能を実現
;;; バッファ名を先頭から入力する必要はなく、とても使いやすくなる
(require 'edmacro)
(iswitchb-mode 1) ;;iswitchbモードON
(defun iswitchb-local-keys ()
  (mapc (lambda (K) 
		  (let* ((key (car K)) (fun (cdr K)))
			(define-key iswitchb-mode-map (edmacro-parse-keys key) fun)))
		'(("<right>" . iswitchb-next-match)
		  ("<left>"  . iswitchb-prev-match)
		  ("<up>"    . ignore             )
		  ("<down>"  . ignore             ))))
(add-hook 'iswitchb-define-mode-map-hook 'iswitchb-local-keys)

(setq iswitchb-buffer-ignore '("^ " "*"))
;;setq iswitchb-buffer-ignore '("^\\*"))
(setq iswitchb-default-method 'samewindow)

(global-set-key [f3] 'iswitchb-buffer)

(defun my-swap-cursor()
  "Swap cursor in two window."
  (interactive)
  (other-window 1) )
(global-set-key [f5] 'my-swap-cursor)

(defun my-kill-ring-save()
  "Copy to kill-ring buffer and discard mark point."
  (interactive)
  (kill-ring-save (region-beginning) (region-end)) 
  (keyboard-quit) )

;Fnキーの定義 MIFESっぽい感じで定義(簡単なので)
(global-set-key [f6] 'set-mark-command)
(global-set-key [f7] 'kill-region)
;(global-set-key [f8] 'my-kill-ring-save)
(global-set-key [f8] 'rgrep)
(global-set-key [f9] 'yank)


(defun window-toggle-division ()
  "ウィンドウ 2 分割時に、縦分割<->横分割"
  (interactive)
  (unless (= (count-windows 1) 2)
	(error "ウィンドウが 2 分割されていません。"))
  (let ((before-height)
		(other-buf (window-buffer (next-window))))
	(setq before-height (window-height))
	(delete-other-windows)
	(if (= (window-height) before-height)
	  (split-window-vertically)
	  (split-window-horizontally))
	(other-window 1)
	(switch-to-buffer other-buf)
	(other-window -1)))

(global-set-key[f4] 'window-toggle-division)


(global-unset-key [(insert)])

(require 'linum)
(line-number-mode 1)
(setq linum-format "%4d|")
(global-linum-mode nil)


;;; *.~ とかのバックアップファイルを作らない
(setq make-backup-files nil)
;;; .#* とかのバックアップファイルを作らない
(setq auto-save-default nil)

;; C-c c で compile コマンドを呼び出す
(define-key mode-specific-map "c" 'compile)
;; C-c C-z で shell コマンドを呼び出す
;(define-key mode-specific-map "¥C-z" 'shell-command)
(define-key mode-specific-map "z" 'shell-command)

;;; GDB 関連
;;; 有用なバッファを開くモード
(setq gdb-many-windows t)
;;; 変数の上にマウスカーソルを置くと値を表示
(add-hook 'gdb-mode-hook '(lambda () (gud-tooltip-mode t)))
;;; I/O バッファを表示
(setq gdb-use-separate-io-buffer t)
;;; t にすると mini buffer に値が表示される
(setq gud-tooltip-echo-area nil)

;;; デフォルトwindowサイズ
(setq initial-frame-alist
	  '((top . 5) (left . 320) (width . 160) (height . 62)))

;;; 分割したwindowサイズ変更 http://d.hatena.ne.jp/mooz/20100119/p1
(defun window-resizer ()
  "Control window size and position."
  (interactive)
  (let ((window-obj (selected-window))
		(current-width (window-width))
		(current-height (window-height))
		(dx (if (= (nth 0 (window-edges)) 0) 1
			  -1))
		(dy (if (= (nth 1 (window-edges)) 0) 1
			  -1))
		c)
	(catch 'end-flag
		   (while t
				  (message "size[%dx%d]"
						   (window-width) (window-height))
				  (setq c (read-char))
				  (cond ((= c ?l)
						 (enlarge-window-horizontally dx))
						((= c ?h)
						 (shrink-window-horizontally dx))
						((= c ?j)
						 (enlarge-window dy))
						((= c ?k)
						 (shrink-window dy))
						;; otherwise
						(t
						  (message "Quit")
						  (throw 'end-flag t)))))))
(global-set-key "\C-c\C-r" 'window-resizer)

;;; font設定
(set-face-attribute 'default nil :family "Inconsolata" :height 104)
