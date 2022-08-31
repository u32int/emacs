; emacs IDE configuration

; disable UI elements
(setq inhibit-startup-message t    ; disable welcome message
      initial-scratch-message nil) ; clear scratch message
(scroll-bar-mode -1)
(tool-bar-mode -1)
(tooltip-mode -1)
(set-fringe-mode 2)
(menu-bar-mode -1)

; configure UI
(column-number-mode) ; enable column display in the modebar
(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'relative)
(set-fringe-mode 2)              ; side padding
(set-face-attribute 'default nil :font "JetBrains Mono Nerd Font" :height 135)
(dolist (mode '(org-mode-hook ; disable line numbers in some buffer types
		vterm-mode-hook
		term-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

; editor behaviour
(setq auto-save-default nil)
(electric-pair-mode 1)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(setq-default indent-tabs-mode nil)

; binds
(global-unset-key "\C-c C-c")
(global-set-key (kbd "C-c c") 'compile)
(global-set-key (kbd "C-c t") 'term)
(global-set-key (kbd "C-c e") 'eval-region)
(global-set-key (kbd "C-c C-r") 'replace-string)

; misc
(setq backup-directory-alist '(("." . "~/.emacs.d/emacs_saves"))) ; set autosave dir
;; https://endlessparentheses.com/ansi-colors-in-the-compilation-buffer-output.html
(require 'ansi-color)
(defun endless/colorize-compilation ()
  "Colorize from `compilation-filter-start' to `point'."
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region
     compilation-filter-start (point))))

(add-hook 'compilation-filter-hook
          #'endless/colorize-compilation)

; misc devel
(add-hook 'c++-mode-hook
          (lambda ()
            (setq c-basic-offset 4
		  c-default-style "linux")))

(add-hook 'c-mode-hook
          (lambda ()
            (setq c-basic-offset 4)))

; NASM/ASM
; https://stackoverflow.com/questions/38672928/how-to-set-emacs-up-for-assembly-programming-and-fix-indentation
(defun my-asm-mode-hook ()
  (electric-indent-local-mode)
  (setq indent-tabs-mode nil)

  (defun asm-calculate-indentation ()
  (or
   (and (looking-at "[.@_[:word:]]+:") 0)
   (and (looking-at "\\s<\\s<\\s<") 0)
   (and (looking-at "%") 0)
   (and (looking-at "c?global\\|section\\|default\\|align\\|INIT_..X") 0)
   (or 4))))
(add-hook 'asm-mode-hook #'my-asm-mode-hook)

;  == PACKAGES ==
; initialize sources
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
 (package-refresh-contents))

(unless (package-installed-p 'use-package)
   (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)


; welcome message/dashboard
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))


(setq dashboard-items '((projects . 7)
                       (recents  . 7)))

(setq dashboard-item-names '(("Projects:"     . "[p] Recent projects:")
                             ("Recent Files:" . "[r] Recent files:")))

(setq dashboard-banner-logo-title (concat "Emacs " emacs-version))
(setq dashboard-show-shortcuts nil)
(setq dashboard-center-content t)
(setq dashboard-set-footer nil)
(setq dashboard-path-style 'truncate-middle)
(setq dashboard-path-max-length 60)


(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

; -- Misc packages --
; color themes
(use-package doom-themes)
(use-package gruber-darker-theme)
(load-theme 'gruber-darker t)

(use-package diminish) ; hides other packages from bar

; -- Editor behaviour packages --
; evil (vim) mode
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

; more evil keybinds
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

; git integration
(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

; completion framework
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

; nicer company ui with icons
(use-package company-box
  :diminish
  :hook (company-mode . company-box-mode))

; snippets
(use-package yasnippet)
(use-package yasnippet-snippets)
(yas-global-mode 1)

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-l")
  :hook (
         (c-mode . lsp)
         (c++-mode . lsp)
         (rustic-mode . lsp)
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

(use-package lsp-ui ; more lsp stuff
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode))
;; https://emacs-lsp.github.io/lsp-mode/tutorials/how-to-turn-off/
(setq lsp-headerline-breadcrumb-enable nil)
(setq lsp-lens-enable nil)
(setq lsp-ui-doc-position "At Point")
(setq lsp-ui-doc-show-with-cursor nil)
(setq lsp-ui-doc-show-with-mouse nil)
(setq lsp-signature-render-documentation nil)

; project manager
(use-package projectile
  :diminish
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/devel")
    (setq projectile-project-search-path '("~/devel")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

; better describe
(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key))

; better syntax highlighting
(use-package tree-sitter-langs)
(use-package tree-sitter
    :diminish
    :after tree-sitter-langs
    :config
    (global-tree-sitter-mode)
    (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

; better m-x, findfile 
(use-package swiper) 
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))
(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))
(use-package counsel
  :diminish
  :bind (("M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

; -- Language Packages -- 
; Rust 
(use-package rustic
  :bind (:map rustic-mode-map
              ("M-l" . lsp-ui-imenu)
              ("M-?" . lsp-find-references)
              ("C-c C-c a" . lsp-execute-code-action)
              ("C-c C-c r" . lsp-rename)
              ("C-c C-c q" . lsp-workspace-restart)
              ("C-c C-c Q" . lsp-workspace-shutdown)
              ("C-c C-c s" . lsp-rust-analyzer-status))
  )
  (setq lsp-eldoc-hook nil)
  ;; (setq lsp-enable-symbol-highlighting nil)
  ;; (setq lsp-signature-auto-activate nil)

  ;; (setq rustic-format-on-save t)

; Python
(use-package elpy
  :init
  (elpy-enable))
(add-hook 'elpy-mode-hook (lambda () (highlight-indentation-mode -1))) ; disable indentation highlighting

; Haskell
(use-package haskell-mode)
(require 'haskell-interactive-mode)
(require 'haskell-process)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(dashboard yasnippet-snippets which-key use-package tree-sitter-langs rustic projectile neotree magit lsp-ui ivy-rich helpful haskell-mode gruber-darker-theme evil-collection elpy elfeed doom-themes diminish counsel company-box)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
