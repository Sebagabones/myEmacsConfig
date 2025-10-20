;;; post-init.el --- This file is loaded after init.el. It is useful for additional configurations or package setups that depend on the configurations in init.el. -*- no-byte-compile: t; lexical-binding: t; -*-

;; Native compilation enhances Emacs performance by converting Elisp code into
;; native machine code, resulting in faster execution and improved
;; responsiveness.
;;
(defmacro use-nix-package (name &rest args)
  `(use-package ,name :elpaca nil ,@args))


;; Ensure adding the following compile-angel code at the very beginning
;; of your `~/.emacs.d/post-init.el` file, before all other packages.
(use-package compile-angel
  :ensure t
  :demand t
  :custom
  ;; Set `compile-angel-verbose` to nil to suppress output from compile-angel.
  ;; Drawback: The minibuffer will not display compile-angel's actions.
  (compile-angel-verbose t)

  :config
  ;; The following directive prevents compile-angel from compiling your init
  ;; files. If you choose to remove this push to `compile-angel-excluded-files'
  ;; and compile your pre/post-init files, ensure you understand the
  ;; implications and thoroughly test your code. For example, if you're using
  ;; `use-package', you'll need to explicitly add `(require 'use-package)` at
  ;; the top of your init file.
  (push "/init.el" compile-angel-excluded-files)
  (push "/early-init.el" compile-angel-excluded-files)
  (push "/pre-init.el" compile-angel-excluded-files)
  (push "/post-init.el" compile-angel-excluded-files)
  (push "/pre-early-init.el" compile-angel-excluded-files)
  (push "/post-early-init.el" compile-angel-excluded-files)

  ;; A local mode that compiles .el files whenever the user saves them.
  ;; (add-hook 'emacs-lisp-mode-hook #'compile-angel-on-save-local-mode)

  ;; A global mode that compiles .el files before they are loaded.
  (compile-angel-on-load-mode))

;;My themeing
(mapc #'disable-theme custom-enabled-themes)  ; Disable all active themes


(use-package doom-themes
  :ensure t
  ;;  :hook  solaire-mode
  :custom
  ;; Global settings (defaults)
  (doom-themes-enable-bold t)   ; if nil, bold is universally disabled
  (doom-themes-enable-italic t) ; if nil, italics is universally disabled
  ;; for treemacs users
  (doom-themes-treemacs-theme "doom-tokyo-night") ; use "doom-colors" for less minimal icon theme


  :config
  (load-theme 'doom-tokyo-night t)

  ;; Enable flashing mode-line on errors
  ;;  (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (nerd-icons must be installed!)
  ;; or for treemacs users
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

;; (use-package catppuccin-theme
;;   :ensure t
;;   :config
;;   (setq catppuccin-flavor 'latte) ;; or 'latte, 'macchiato, or 'mocha
;;   ;; (load-theme 'catppuccin :no-confirm)
;;   ;; ;; (catppuccin-reload)
;;   )
(use-package base16-theme
  :ensure t
  )
(use-package  solaire-mode
  :ensure t
  :config
  ;; (add-to-list 'solaire-mode-themes-to-face-swap "doom-tokyo-night")
  :custom
  (solaire-global-mode +1)
  )
;; Auto-revert in Emacs is a feature that automatically updates the
;; contents of a buffer to reflect changes made to the underlying file
;; on disk.
(add-hook 'elpaca-after-init-hook #'global-auto-revert-mode)

;; recentf is an Emacs package that maintains a list of recently
;; accessed files, making it easier to reopen files you have worked on
;; recently.
(add-hook 'elpaca-after-init-hook #'(lambda()
                                      (let ((inhibit-message t))
                                        (recentf-mode 1))))

(with-eval-after-load "recentf"
  (add-hook 'kill-emacs-hook #'recentf-cleanup))

;; savehist is an Emacs feature that preserves the minibuffer history between
;; sessions. It saves the history of inputs in the minibuffer, such as commands,
;; search strings, and other prompts, to a file. This allows users to retain
;; their minibuffer history across Emacs restarts.
(add-hook 'elpaca-after-init-hook #'savehist-mode)

;; save-place-mode enables Emacs to remember the last location within a file
;; upon reopening. This feature is particularly beneficial for resuming work at
;; the precise point where you previously left off.
(add-hook 'elpaca-after-init-hook #'save-place-mode)

;; When auto-save-visited-mode is enabled, Emacs will auto-save file-visiting
;; buffers after a certain amount of idle time if the user forgets to save it
;; with save-buffer or C-x s for example.
;;
;; This is different from auto-save-mode: auto-save-mode periodically saves
;; all modified buffers, creating backup files, including those not associated
;; with a file, while auto-save-visited-mode only saves file-visiting buffers
;; after a period of idle time, directly saving to the file itself without
;; creating backup files.
(setq auto-save-visited-interval 5)   ; Save after 5 seconds if inactivity
(auto-save-visited-mode 1)



;; Corfu enhances in-buffer completion by displaying a compact popup with
;; current candidates, positioned either below or above the point. Candidates
;; can be selected by navigating up or down.
(use-package corfu
  :custom
  (corfu-auto t)               ;; Enable auto completion
  (corfu-preselect 'directory) ;; Select the first candidate, except for directories

  :ensure t
  ;; :custom
  :commands (corfu-mode global-corfu-mode)
  :hook ((prog-mode . corfu-mode)
         (shell-mode . corfu-mode)
         (eshell-mode . corfu-mode))
  :custom
  ;; Hide commands in M-x which do not apply to the current mode.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Disable Ispell completion function. As an alternative try `cape-dict'.
  (text-mode-ispell-word-completion nil)
  (tab-always-indent 'complete)

  ;; Enable Corfu
  :config
  ;; Free the RET key for less intrusive behavior.
  (keymap-unset corfu-map "RET")
  (global-corfu-mode)
  )

;; Cape, or Completion At Point Extensions, extends the capabilities of
;; in-buffer completion. It integrates with Corfu or the default completion UI,
;; by providing additional backends through completion-at-point-functions.
(use-package cape
  :ensure t
  :commands (cape-file cape-elisp-block)
  :bind ("C-c p" . cape-prefix-map)
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.
  ;; (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))

;; Vertico provides a vertical completion interface, making it easier to
;; navigate and select from completion candidates (e.g., when `M-x` is pressed).
(use-package vertico
  ;; (Note: It is recommended to also enable the savehist package.)
  :ensure t
  :config
  (vertico-mode))


;; Vertico leverages Orderless' flexible matching capabilities, allowing users
;; to input multiple patterns separated by spaces, which Orderless then
;; matches in any order against the candidates.
(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; Marginalia allows Embark to offer you preconfigured actions in more contexts.
;; In addition to that, Marginalia also enhances Vertico by adding rich
;; annotations to the completion candidates displayed in Vertico's interface.
(use-package marginalia
  :ensure t
  :commands (marginalia-mode marginalia-cycle)
  ;; :init
  ;; :defer t
  ;; (marginalia-mode))
  :hook (elpaca-after-init . marginalia-mode))

;; Embark integrates with Consult and Vertico to provide context-sensitive
;; actions and quick access to commands based on the current selection, further
;; improving user efficiency and workflow within Emacs. Together, they create a
;; cohesive and powerful environment for managing completions and interactions.
(use-package embark
  ;; Embark is an Emacs package that acts like a context menu, allowing
  ;; users to perform context-sensitive actions on selected items
  ;; directly from the completion interface.
  :ensure t
  :commands (embark-act
             embark-dwim
             embark-export
             embark-collect
             embark-bindings
             embark-prefix-help-command)
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init
  (setq prefix-help-command #'embark-prefix-help-command)

  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Consult offers a suite of commands for efficient searching, previewing, and
;; interacting with buffers, file contents, and more, improving various tasks.
(use-package consult
  :ensure t
  :bind (;; C-c bindings in x`mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x t b" . consult-buffer-other-tab)
         ("C-x r b" . consult-bookmark)
         ("C-x p b" . consult-project-buffer)
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("C-s" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)
         ("M-r" . consult-history))

  ;; Enable automatic preview at point in the *Completions* buffer.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  :init
  ;; Optionally configure the register formatting. This improves the register
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  ;; Aggressive asynchronous that yield instantaneous results. (suitable for
  ;; high-performance systems.) Note: Minad, the author of Consult, does not
  ;; recommend aggressive values.
  ;; Read: https://github.com/minad/consult/discussions/951
  ;;
  ;; However, the author of minimal-emacs.d uses these parameters to achieve
  ;; immediate feedback from Consult.
  ;; (setq consult-async-input-debounce 0.02
  ;;       consult-async-input-throttle 0.05
  ;;       consult-async-refresh-delay 0.02)

  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))
  (setq consult-narrow-key "<"))

;; The built-in outline-minor-mode provides structured code folding in modes
;; such as Emacs Lisp and Python, allowing users to collapse and expand sections
;; based on headings or indentation levels. This feature enhances navigation and
;; improves the management of large files with hierarchical structures.
(use-package outline-indent
  :ensure t
  :commands outline-indent-minor-mode

  :custom
  (outline-indent-ellipsis " ▼ ")

  :init
  ;; The minor mode can also be automatically activated for a certain modes.
  (add-hook 'python-mode-hook #'outline-indent-minor-mode)
  (add-hook 'python-ts-mode-hook #'outline-indent-minor-mode)

  (add-hook 'yaml-mode-hook #'outline-indent-minor-mode)
  (add-hook 'yaml-ts-mode-hook #'outline-indent-minor-mode))


;; The stripspace Emacs package provides stripspace-local-mode, a minor mode
;; that automatically removes trailing whitespace and blank lines at the end of
;; the buffer when saving.
(use-package stripspace
  :ensure t
  :commands stripspace-local-mode

  ;; Enable for prog-mode-hook, text-mode-hook, conf-mode-hook
  :hook ((prog-mode . stripspace-local-mode)
         (text-mode . stripspace-local-mode)
         (conf-mode . stripspace-local-mode))

  :custom
  ;; The `stripspace-only-if-initially-clean' option:
  ;; - nil to always delete trailing whitespace.
  ;; - Non-nil to only delete whitespace when the buffer is clean initially.
  ;; (The initial cleanliness check is performed when `stripspace-local-mode'
  ;; is enabled.)
  (stripspace-only-if-initially-clean nil)

  ;; Enabling `stripspace-restore-column' preserves the cursor's column position
  ;; even after stripping spaces. This is useful in scenarios where you add
  ;; extra spaces and then save the file. Although the spaces are removed in the
  ;; saved file, the cursor remains in the same position, ensuring a consistent
  ;; editing experience without affecting cursor placement.
  (stripspace-restore-column t))

;; The undo-fu package is a lightweight wrapper around Emacs' built-in undo
;; system, providing more convenient undo/redo functionality.
(use-package undo-fu
  :ensure t
  :commands (undo-fu-only-undo
             undo-fu-only-redo
             undo-fu-only-redo-all
             undo-fu-disable-checkpoint)
  :config
  (global-unset-key (kbd "C-z")))


;; The undo-fu-session package complements undo-fu by enabling the saving
;; and restoration of undo history across Emacs sessions, even after restarting.
;; (use-package undo-fu-session
;;   :ensure t
;;   :hook (elpaca-after-init . undo-fu-session-global-mode))
(use-package undo-fu-session
  :ensure t
  :init
  (undo-fu-session-global-mode))

;; Give Emacs sessions-bar a style similar to Vim's
(use-package vim-tab-bar
  :ensure t
  :commands vim-tab-bar-mode
  :hook (elpaca-after-init . vim-tab-bar-mode))

(use-package ox-gfm
  :ensure t
  :init
  (eval-after-load "org"
    '(require 'ox-gfm nil t)))

;; (use-package olivetti
;;   :ensure t
;;   :custom
;;   (olivetti-body-width 86)
;;   :config
;;   (setq olivetti-style t))

(use-package org-modern-indent
  :straight (org-modern-indent :type git :host github :repo "jdtsmith/org-modern-indent")
  :ensure t
  :hook org-mode)

(use-package org-bullets-mode
  :ensure org-bullets
  :config
  :hook org-mode)

(use-package org-modern
  :ensure t
  :custom
  (org-modern-hide-stars nil)		; adds extra indentation
  (org-modern-table nil)
  (org-modern-list
   '(;; (?- . "-")
     (?* . "•")
     (?+ . "‣")))
  :config
  (setq
   org-auto-align-tags t
   org-tags-column 0
   org-fold-catch-invisible-edits 'show-and-error
   org-special-ctrl-a/e t
   org-insert-heading-respect-content t

   ;; ;; Don't style the following
   ;; org-modern-tag nil
   ;; org-modern-priority nil
   ;; org-modern-todo nil
   ;; org-modern-table nil

   ;; Agenda styling
   org-agenda-tags-column 0
   org-agenda-block-separator ?─
   org-agenda-time-grid
   '((daily today require-timed)
	 (800 1000 1200 1400 1600 1800 2000)
	 " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
   org-agenda-current-time-string
   "⭠ now ─────────────────────────────────────────────────")
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda)
  (org-mode . global-org-modern-mode))

(use-package org-appear
  :commands (org-appear-mode)
  :hook     (org-mode . org-appear-mode)
  :config
  (setq org-hide-emphasis-markers t)  ;; Must be activated for org-appear to work
  (setq org-appear-autoemphasis   t   ;; Show bold, italics, verbatim, etc.
        org-appear-autolinks      t   ;; Show links
        org-appear-autosubmarkers t)) ;; Show sub- and superscripts

(use-package org-fragtog
  :after org
  :hook (org-mode . org-fragtog-mode))

(use-package engrave-faces
  :ensure t
  :after ox-latex
  :init
  (setq org-latex-src-block-backend 'engraved
        ;; org-latex-engraved-theme 'doom-tokyo-night))
        ))



(use-package org-attach-screenshot
  :bind ("C-c C-x s" . org-attach-screenshot)
  :config (setq org-attach-screenshot-dirfunction
		        (lambda ()
		          (progn (cl-assert (buffer-file-name))
			             (concat (file-name-sans-extension (buffer-file-name))
				                 "-att")))
		        org-attach-screenshot-command-line "gnome-screenshot -a -f %f"))

(use-package org-sidebar
  :straight (:type git :host github :repo "alphapapa/org-sidebar")
  :ensure t
  )
;; org mode is a major mode designed for organizing notes, planning, task
;; management, and authoring documents using plain text with a simple and
;; expressive markup syntax. It supports hierarchical outlines, TODO lists,
;; scheduling, deadlines, time tracking, and exporting to multiple formats
;; including HTML, LaTeX, PDF, and Markdown.
(use-package org
  :ensure t
  :commands (org-mode org-version)
  :mode
  ("\\.org\\'" . org-mode)
  :hook
  (org-mode . visual-line-mode)
  ;; (org-mode . olivetti-mode)
  (org-mode . org-indent-mode)
  ;; (org-mode . org-modern-indent-mode)

  :config
  (setq org-directory "~/Org/")
  ;; lualatex setup from https://stackoverflow.com/questions/41568410/configure-org-mode-to-use-lualatex

  (setq org-latex-pdf-process
        '("latexmk -lualatex -shell-escape -interaction=nonstopmode  %f"))
  ;; (setq org-latex-pdf-process
  ;;       '("lualatex -pdflatex=-shell-escape -interaction nonstopmode %f"
  ;;         "lualatex -shell-escape -interaction nonstopmode %f"))

  (setq luasvg '(luasvg :programs ("dvilualatex""dvisvgm") :description "dvi > svg" :message
                        "you need to install the programs: lualatex and dvisvgm."
                        :image-input-type "dvi" :image-output-type "svg" :image-size-adjust
                        (1.7 . 1.5) :latex-compiler
                        ("dvilualatex -interaction nonstopmode -output-directory %o %f")
                        :image-converter
                        ("dvisvgm %f --no-fonts --exact-bbox --scale=%S --output=%O")))

  (add-to-list 'org-preview-latex-process-alist luasvg)
  (require 'ox-latex)
  ;; (add-to-list 'org-latex-packages-alist '("" "minted" nil))
  ;; (setq org-latex-src-block-backend 'minted)
  (setq org-engraved-minted-options
        '(("frame" "leftline")
          ("linenos" "true")
          ("numberblanklines" "false")
          ("showspaces" "false")
          ("breaklines" "true")
          ))
  (setq org-latex-src-block-backend 'engraved)

  ;; (add-to-list 'org-latex-packages-alist '("" "xcolor" nil))
  (add-to-list 'org-latex-packages-alist '("" "fvextra" nil))
  (add-to-list 'org-latex-packages-alist '("" "upquote" nil))
  (add-to-list 'org-latex-packages-alist '("" "booktabs" nil))

  ;; (add-to-list 'org-latex-packages-alist '("" "lineno" nil))

  ;; (add-to-list 'org-latex-packages-alist '("" "hyperref" nil))
  ;; (add-to-list 'org-latex-packages-alist '("" "geometry" nil))
  ;; (customize-set-variable 'org-format-latex-header
  ;;                         (concat org-format-latex-header "\n\\setlength{\\parindent}{0pt}\n\\hypersetup{colorlinks=false, hidelinks=true}\n\\newgeometry{vmargin={15mm}, hmargin={17mm,17mm}}"))

  (defun org-html--format-image (source attributes info) ;base64 encodes images on export to HTML
    (format "<img src=\"data:image/%s;base64,%s\"%s />"
            (or (file-name-extension source) "")
            (base64-encode-string
             (with-temp-buffer
	           (insert-file-contents-literally source)
	           (buffer-string)))
            (file-name-nondirectory source)))
  :custom
  (org-preview-latex-default-process 'luasvg)
  (org-hide-leading-stars t)
  (org-html-validation-link nil)
  (org-startup-indented t)
  (org-edit-src-content-indentation 0)
  (org-link-search-must-match-exact-headline nil)
  (org-fontify-done-headline t)
  (org-fontify-todo-headline t)
  (org-fontify-whole-heading-line t)
  (org-fontify-quote-and-verse-blocks t)
  (org-startup-truncated t)
  (org-latex-compiler "lualatex")
  (org-adapt-indentation t)
  (org-hide-emphasis-markers t)
  (org-pretty-entities t)
  (org-agenda-tags-column 0)
  (org-ellipsis "…")
  (org-latex-tables-booktabs t)
  (org-footnote-auto-adjust t)
  (org-lowest-priority ?F "Gives us priorities A through F")  ;;Gives us priorities A through F
  (org-default-priority ?E "If an item has no priority, it is considered [#E]") ;; If an item has no priority, it is considered [#E].
  ;; (setq org-preview-latex-default-process 'dvisvgm))
  )

(defun org-show-todo-tree ()
  "Create new indirect buffer with sparse tree of undone TODO items"
  (interactive)
  (clone-indirect-buffer "*org TODO undone*" t)
  (org-show-todo-tree nil)
  (org-remove-occur-highlights))

(setq org-todo-keywords
      '((sequence "TODO(t)" "|" "DONE(d)")
        (sequence "REPORT(r)" "BUG(b)" "KNOWNCAUSE(k)" "|" "FIXED(f)")
        (sequence "|" "CANCELED(c)")))

(setq org-publish-project-alist
      '(
        ("org-notes"
         :base-directory "~/Org/"
         :publishing-function org-html-publish-to-html
         :publishing-directory "~/Org/public"
         ;; :section-numbers nil
         ;; :with-toc nil
         :recursive "t")
        ;; :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"css/.tufte.css\" /><link rel=\"stylesheet\" type=\"text/css\" href=\"css/.srctufte.css\"/><link rel=\"stylesheet\" type=\"text/css\" href=\"css/.style.css\" />")
        ;; :html-head "<link rel=\"stylesheet\" type=\"text/css\" href=\"~/Org/.style.css\" />"))
        ("org-static"
         :base-directory "~/Org/css/"
         :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
         :publishing-directory "~/Org/public"
         :recursive t
         :publishing-function org-publish-attachment
         )
        ("org" :components ("org-notes" "org-static")))
      )

(use-package htmlize
  :defer t)

;; The markdown-mode package provides a major mode for Emacs for syntax
;; highlighting, editing commands, and preview support for Markdown documents.
;; It supports core Markdown syntax as well as extensions like GitHub Flavored
;; Markdown (GFM).
(use-package markdown-mode
  :commands (gfm-mode
             gfm-view-mode
             markdown-mode
             markdown-view-mode)
  :mode (("\\.markdown\\'" . markdown-mode)
         ("\\.md\\'" . markdown-mode)
         ("README\\.md\\'" . gfm-mode))
  :init
  (setq markdown-command "multimarkdown")

  :bind
  (:map markdown-mode-map
        ("C-c C-e" . markdown-do)))

;; ;; Tree-sitter in Emacs is an incremental parsing system introduced in Emacs 29
;; ;; that provides precise, high-performance syntax highlighting. It supports a
;; ;; broad set of programming languages, including Bash, C, C++, C#, CMake, CSS,
;; ;; Dockerfile, Go, Java, JavaScript, JSON, Python, Rust, TOML, TypeScript, YAML,
;; ;; Elisp, Lua, Markdown, and many others.
;; (use-package treesit-auto
;;   :ensure t
;;   :custom
;;   (treesit-auto-install 'prompt)
;;   :config
;;   (treesit-auto-add-to-auto-mode-alist 'all)
;;   (global-treesit-auto-mode))

;; A file and project explorer for Emacs that displays a structured tree
;; layout, similar to file browsers in modern IDEs. It functions as a sidebar
;; in the left window, providing a persistent view of files, projects, and
;; other elements.
(use-nix-package treemacs
                 ;; :ensure t
                 :elpaca nil
                 :commands (treemacs
                            treemacs-select-window
                            treemacs-delete-other-windows
                            treemacs-select-directory
                            treemacs-bookmark
                            treemacs-find-file
                            treemacs-find-tag)

                 :bind
                 (:map global-map
                       ("M-0"       . treemacs-select-window)

                       ("C-x t 1"   . treemacs-delete-other-windows)
                       ("C-x t t"   . treemacs)
                       ("C-x t d"   . treemacs-select-directory)
                       ("C-x t B"   . treemacs-bookmark)
                       ("C-x t C-t" . treemacs-find-file)
                       ("C-x t M-t" . treemacs-find-tag))

                 :init
                 (with-eval-after-load 'winum
                   (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))

                 :config
                 (setq treemacs-collapse-dirs                   (if treemacs-python-executable 3 0)
                       treemacs-deferred-git-apply-delay        0.5
                       treemacs-directory-name-transformer      #'identity
                       treemacs-display-in-side-window          t
                       treemacs-eldoc-display                   'simple
                       treemacs-file-event-delay                2000
                       treemacs-file-extension-regex            treemacs-last-period-regex-value
                       treemacs-file-follow-delay               0.2
                       treemacs-file-name-transformer           #'identity
                       treemacs-follow-after-init               t
                       treemacs-expand-after-init               t
                       treemacs-find-workspace-method           'find-for-file-or-pick-first
                       treemacs-git-command-pipe                ""
                       treemacs-goto-tag-strategy               'refetch-index
                       treemacs-header-scroll-indicators        '(nil . "^^^^^^")
                       treemacs-hide-dot-git-directory          t
                       treemacs-indentation                     2
                       treemacs-indentation-string              " "
                       treemacs-is-never-other-window           nil
                       treemacs-max-git-entries                 5000
                       treemacs-missing-project-action          'ask
                       treemacs-move-files-by-mouse-dragging    t
                       treemacs-move-forward-on-expand          nil
                       treemacs-no-png-images                   nil
                       treemacs-no-delete-other-windows         t
                       treemacs-project-follow-cleanup          nil
                       treemacs-persist-file                    (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
                       treemacs-position                        'left
                       treemacs-read-string-input               'from-child-frame
                       treemacs-recenter-distance               0.1
                       treemacs-recenter-after-file-follow      nil
                       treemacs-recenter-after-tag-follow       nil
                       treemacs-recenter-after-project-jump     'always
                       treemacs-recenter-after-project-expand   'on-distance
                       treemacs-litter-directories              '("/node_modules" "/.venv" "/.cask")
                       treemacs-project-follow-into-home        nil
                       treemacs-show-cursor                     nil
                       treemacs-show-hidden-files               t
                       treemacs-silent-filewatch                nil
                       treemacs-silent-refresh                  nil
                       treemacs-sorting                         'alphabetic-asc
                       treemacs-select-when-already-in-treemacs 'move-back
                       treemacs-space-between-root-nodes        t
                       treemacs-tag-follow-cleanup              t
                       treemacs-tag-follow-delay                1.5
                       treemacs-text-scale                      nil
                       treemacs-user-mode-line-format           nil
                       treemacs-user-header-line-format         nil
                       treemacs-wide-toggle-width               70
                       treemacs-width                           35
                       treemacs-width-increment                 1
                       treemacs-width-is-initially-locked       t
                       treemacs-workspace-switch-cleanup        nil)

                 ;; The default width and height of the icons is 22 pixels. If you are
                 ;; using a Hi-DPI display, uncomment this to double the icon size.
                 ;; (treemacs-resize-icons 44)

                 (treemacs-follow-mode t)
                 (treemacs-filewatch-mode t)
                 (treemacs-fringe-indicator-mode 'always)

                 ;;(when treemacs-python-executable
                 ;;  (treemacs-git-commit-diff-mode t))

                 (pcase (cons (not (null (executable-find "git")))
                              (not (null treemacs-python-executable)))
                   (`(t . t)
                    (treemacs-git-mode 'deferred))
                   (`(t . _)
                    (treemacs-git-mode 'simple)))

                 (treemacs-hide-gitignored-files-mode nil))


(use-package ispell
  :ensure nil
  :commands (ispell ispell-minor-mode)
  :custom
  ;; Set the ispell program name to aspell
  (ispell-program-name "aspell")

  ;; Configures Aspell's suggestion mode to "ultra", which provides more
  ;; aggressive and detailed suggestions for misspelled words. The language
  ;; is set to "en_US" for US English, which can be replaced with your desired
  ;; language code (e.g., "en_GB" for British English, "de_DE" for German).
  (ispell-extra-args '("--sug-mode=ultra" "--lang=en_GB")))

;; The flyspell package is a built-in Emacs minor mode that provides
;; on-the-fly spell checking. It highlights misspelled words as you type,
;; offering interactive corrections.
(use-package flyspell
  :ensure nil
  :commands flyspell-mode
  :hook
  (;(prog-mode . flyspell-prog-mode)
   (text-mode . (lambda()
                  (if (or (derived-mode-p 'yaml-mode)
                          (derived-mode-p 'yaml-ts-mode)
                          (derived-mode-p 'ansible-mode))
                      (flyspell-prog-mode 1)
                    (flyspell-mode 1)))))
  :config
  ;; Remove strings from Flyspell
  (setq flyspell-prog-text-faces (delq 'font-lock-string-face
                                       flyspell-prog-text-faces))

  ;; Remove doc from Flyspell
  (setq flyspell-prog-text-faces (delq 'font-lock-doc-face
                                       flyspell-prog-text-faces)))

;; Apheleia is an Emacs package designed to run code formatters (e.g., Shfmt,
;; Black and Prettier) asynchronously without disrupting the cursor position.
(use-package apheleia
  :ensure t
  :commands (apheleia-mode
             apheleia-global-mode)
  :hook ((prog-mode . apheleia-mode))
  :config
  ;; Replace default (black) to use ruff for sorting import and formatting.
  (setf (alist-get 'python-mode apheleia-mode-alist)
        '(ruff-isort ruff))
  (setf (alist-get 'python-mode apheleia-mode-alist)
        '(ruff-isort ruff)))

;; Enables automatic indentation of code while typing
(use-package aggressive-indent
  :ensure t
  :commands aggressive-indent-mode
  :hook
  (emacs-lisp-mode . aggressive-indent-mode))

;; Highlights function and variable definitions in Emacs Lisp mode
(use-package highlight-defined
  :ensure t
  :commands highlight-defined-mode
  :hook
  (emacs-lisp-mode . highlight-defined-mode))

;; Prevent parenthesis imbalance
;; (use-package paredit
;;   :ensure t
;;   :commands paredit-mode
;;   :hook
;;   (emacs-lisp-mode . paredit-mode)
;;   :config
;;   (define-key paredit-mode-map (kbd "RET") nil))

;; Helpful is an alternative to the built-in Emacs help that provides much more
;; contextual information.
(use-package helpful
  :ensure t
  :commands (helpful-callable
             helpful-variable
             helpful-key
             helpful-command
             helpful-at-point
             helpful-function)
  :bind
  ([remap describe-command] . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-key] . helpful-key)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  :custom
  (helpful-max-buffers 7))


;; Configure the `tab-bar-show` variable to 1 to display the tab bar exclusively
;; when multiple tabs are open:
(setopt tab-bar-show 1)

;; Prevent Emacs from saving customization information to a custom file
(setq custom-file null-device)

(use-package nerd-icons
  :ensure t)

;; (add-to-list 'default-frame-alist '(font . "JetBrainsMono NFM 12"))
;; (set-face-attribute 'default nil :font "JetBrainsMono NFM 12")

;; (set-frame-font "JetBrainsMono NFM 12" nil t)
;; (use-package ligature ;setup for jetbrains
;;   :ensure t
;;   :config
;;   (ligature-set-ligatures 'prog-mode '("--" "---" "==" "===" "!=" "!==" "=!="
;;                                        "=:=" "=/=" "<=" ">=" "&&" "&&&" "&=" "++" "+++" "***" ";;" "!!"
;;                                        "??" "???" "?:" "?." "?=" "<:" ":<" ":>" ">:" "<:<" "<>" "<<<" ">>>"
;;                                        "<<" ">>" "||" "-|" "_|_" "|-" "||-" "|=" "||=" "##" "###" "####"
;;                                        "#{" "#[" "]#" "#(" "#?" "#_" "#_(" "#:" "#!" "#=" "^=" "<$>" "<$"
;;                                        "$>" "<+>" "<+" "+>" "<*>" "<*" "*>" "</" "</>" "/>" "<!--" "<#--"
;;                                        "-->" "->" "->>" "<<-" "<-" "<=<" "=<<" "<<=" "<==" "<=>" "<==>"
;;                                        "==>" "=>" "=>>" ">=>" ">>=" ">>-" ">-" "-<" "-<<" ">->" "<-<" "<-|"
;;                                        "<=|" "|=>" "|->" "<->" "<~~" "<~" "<~>" "~~" "~~>" "~>" "~-" "-~"
;;                                        "~@" "[||]" "|]" "[|" "|}" "{|" "[<" ">]" "|>" "<|" "||>" "<||"
;;                                        "|||>" "<|||" "<|>" "..." ".." ".=" "..<" ".?" "::" ":::" ":=" "::="
;;                                        ":?" ":?>" "//" "///" "/*" "*/" "/=" "//=" "/==" "@_" "__" "???"
;;                                        "<:<" ";;;"))
;;   (global-ligature-mode t))
(use-package fira-code-mode
  :custom (fira-code-mode-disabled-ligatures '("[]" "x" "//" "||" "lambda" "or" "and"))  ; ligatures you don't want
  :hook (prog-mode org-mode))                                         ; mode to enable fira-code-mode in




;; Allow Emacs to upgrade built-in packages, such as Org mode
(setq package-install-upgrade-built-in t)

;; When Delete Selection mode is enabled, typed text replaces the selection
;; if the selection is active.
(delete-selection-mode 1)

;; Display the current line and column numbers in the mode line
(setq line-number-mode t)
(setq column-number-mode t)
(setq mode-line-position-column-line-format '("%l:%C"))

;; Display of line numbers in the buffer:
;; (setq-default display-line-numbers-type 'relative)
(setq-default display-line-numbers-type 't)
(dolist (hook '(prog-mode-hook text-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

(use-package which-key
  :ensure nil ; builtin
  :commands which-key-mode
  :hook (elpaca-after-init . which-key-mode)
  :custom
  (which-key-idle-delay 1.5)
  (which-key-idle-secondary-delay 0.25)
  (which-key-add-column-padding 1)
  (which-key-max-description-length 40))

(unless (and (eq window-system 'mac)
             (bound-and-true-p mac-carbon-version-string))
  ;; Enables `pixel-scroll-precision-mode' on all operating systems and Emacs
  ;; versions, except for emacs-mac.
  ;;
  ;; Enabling `pixel-scroll-precision-mode' is unnecessary with emacs-mac, as
  ;; this version of Emacs natively supports smooth scrolling.
  ;; https://bitbucket.org/mituharu/emacs-mac/commits/65c6c96f27afa446df6f9d8eff63f9cc012cc738
  (setq pixel-scroll-precision-use-momentum nil) ; Precise/smoother scrolling
  (pixel-scroll-precision-mode 1))

;; Display the time in the modeline
(add-hook 'elpaca-after-init-hook #'display-time-mode)

;; Paren match highlighting
(add-hook 'elpaca-after-init-hook #'show-paren-mode)

;; Track changes in the window configuration, allowing undoing actions such as
;; closing windows.
(add-hook 'elpaca-after-init-hook #'winner-mode)

;; Replace selected text with typed text
;; (delete-selection-mode 1)

(use-package uniquify
  :ensure nil
  :custom
  (uniquify-buffer-name-style 'reverse)
  (uniquify-separator "•")
  (uniquify-after-kill-buffer-p t))

;; Window dividers separate windows visually. Window dividers are bars that can
;; be dragged with the mouse, thus allowing you to easily resize adjacent
;; windows.
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Window-Dividers.html
(add-hook 'elpaca-after-init-hook #'window-divider-mode)

;; Dired buffers: Automatically hide file details (permissions, size,
;; modification date, etc.) and all the files in the `dired-omit-files' regular
;; expression for a cleaner display.
(add-hook 'dired-mode-hook #'dired-hide-details-mode)

;; Hide files from dired
(setq dired-omit-files (concat "\\`[.]\\'"
                               "\\|\\(?:\\.js\\)?\\.meta\\'"
                               "\\|\\.\\(?:elc|a\\|o\\|pyc\\|pyo\\|swp\\|class\\)\\'"
                               "\\|^\\.DS_Store\\'"
                               "\\|^\\.\\(?:svn\\|git\\)\\'"
                               "\\|^\\.ccls-cache\\'"
                               "\\|^__pycache__\\'"
                               "\\|^\\.project\\(?:ile\\)?\\'"
                               "\\|^flycheck_.*"
                               "\\|^flymake_.*"))
(add-hook 'dired-mode-hook #'dired-omit-mode)

;; Enables visual indication of minibuffer recursion depth after initialization.
(add-hook 'elpaca-after-init-hook #'minibuffer-depth-indicate-mode)

;; Configure Emacs to ask for confirmation before exiting
(setq confirm-kill-emacs 'y-or-n-p)

;; Enabled backups save your changes to a file intermittently
(setq make-backup-files t)
(setq vc-make-backup-files t)
(setq kept-old-versions 10)
(setq kept-new-versions 10)

(setq epg-gpg-program "gpg2")
(setenv "GPG_AGENT_INFO" nil)

(setq auth-sources '("~/.authinfo.gpg"))
;; Improve Emacs responsiveness by deferring fontification during input
;;
;; NOTE: This may cause delayed syntax highlighting in certain cases
(setq redisplay-skip-fontification-on-input t)


;; my custom junk that will probably slowww this down
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))


(setq visible-bell t)

(use-package transient)

(use-package magit
  :after transient
  :ensure t
  ;; :after
  ;; (setq magit-diff-refine-hunk 't))
  )
(use-package difftastic
  :demand t
  :bind (:map magit-blame-read-only-mode-map
              ("D" . difftastic-magit-show)
              ("S" . difftastic-magit-show))
  :config
  (eval-after-load 'magit-diff
    '(transient-append-suffix 'magit-diff '(-1 -1)
       [("D" "Difftastic diff (dwim)" difftastic-magit-diff)
        ("S" "Difftastic show" difftastic-magit-show)])))

(use-package magit-delta
  :after transient
  :hook (magit-mode . magit-delta-mode)
  :config
  (setq magit-delta-delta-args
        `("--syntax-theme" "tokyoNightNight"
          ;; `("--syntax-theme" "Dracula"
          "--max-line-distance" "0.6"
          "--true-color" "always"
          "--color-only")))

(defun myfun/toggle-magit-delta ()
  (interactive)
  (magit-delta-mode
   (if magit-delta-mode
       -1
     1))
  (magit-refresh))

(with-eval-after-load 'magit
  (transient-append-suffix 'magit-diff '(-1 -1 -1)
    '("D" "Toggle magit-delta" myfun/toggle-magit-delta))) ;Borrowed from https://shivjm.blog/better-magit-diffs/


(use-package hydra
  :after magit
  :config                               ;From https://github.com/alphapapa/unpackaged.el#smerge-mode
  (defhydra unpackaged/smerge-hydra
    (:color pink :hint nil :post (smerge-auto-leave))
    "
^Move^       ^Keep^               ^Diff^                 ^Other^
^^-----------^^-------------------^^---------------------^^-------
_n_ext       _b_ase               _<_: upper/base        _C_ombine
_p_rev       _u_pper              _=_: upper/lower       _r_esolve
^^           _l_ower              _>_: base/lower        _k_ill current
^^           _a_ll                _R_efine
^^           _RET_: current       _E_diff
"
    ("n" smerge-next)
    ("p" smerge-prev)
    ("b" smerge-keep-base)
    ("u" smerge-keep-upper)
    ("l" smerge-keep-lower)
    ("a" smerge-keep-all)
    ("RET" smerge-keep-current)
    ("\C-m" smerge-keep-current)
    ("<" smerge-diff-base-upper)
    ("=" smerge-diff-upper-lower)
    (">" smerge-diff-base-lower)
    ("R" smerge-refine)
    ("E" smerge-ediff)
    ("C" smerge-combine-with-next)
    ("r" smerge-resolve)
    ("k" smerge-kill-current)
    ("ZZ" (lambda ()
            (interactive)
            (save-buffer)
            (bury-buffer))
     "Save and bury buffer" :color blue)
    ("q" nil "cancel" :color blue))
  :hook (magit-diff-visit-file . (lambda ()
                                   (when smerge-mode
                                     (unpackaged/smerge-hydra/body)))))


(use-package exec-path-from-shell
  :defer t
  :init
  (setq exec-path-from-shell-arguments nil)
  (exec-path-from-shell-initialize))

;; (use-package company
;;   :defer t
;;   :bind
;;   (:map company-active-map
;;         ("<tab>" . company-complete-selection))
;;   :init
;;   (global-company-mode))

(use-package projectile
  :defer t
  :init
  (projectile-mode))

(use-package rg
  :after transient
  :defer t)

(use-package flycheck
  :defer t
  :hook (elpaca-after-init . global-flycheck-mode)

  :config
  (setq flycheck-highlighting-mode "lines")
  (setq lsp-diagnostics-provider :none)
  )


(use-package flycheck-inline
  :after flycheck
  :hook (flycheck-mode . flycheck-inline-mode))

(use-package scad-mode
  :ensure t)

(use-package scad-preview
  :after scad-mode
  :ensure t
  :straight (:host github :repo "zk-phi/scad-preview" :branch "master")
  )

(use-package scad-dbus
  :after scad-mode
  :straight (:host github :repo "Lenbok/scad-dbus" :branch "master")
  :bind (:map scad-mode-map ("C-c o" . 'hydra-scad-dbus/body)))

;; LSP setup from https://emacs-lsp.github.io/lsp-mode/page/installation/
(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :ensure t
  :hook(
        (python-mode . lsp-deferred)
        (nix-mode . lsp-deferred)
        (c-mode . lsp-deferred)
        (c++-mode . lsp-deferred)
        (scad-mode . lsp-deferred)
        ;; Add more major modes here
        (lsp-mode . lsp-enable-which-key-integration))
  :commands  (lsp lsp-deferred))

(use-package lsp-pyright
  :ensure t
  :custom (lsp-pyright-langserver-command "basedpyright") ;; or pyright
  :hook ((python-mode python-ts-mode) . (lambda ()
                                          (require 'lsp-pyright)
                                          (lsp-deferred))))  ; or lsp

(use-package lsp-ui
  :defer t
  :after lsp-mode
  :bind (("C-c c l f" . lsp-ui-doc-focus-frame)
         ("C-c c l u" . lsp-ui-doc-unfocus-frame))
  ;;:commands lsp-ui-mode                 ;

  :config
  (lsp-ui-peek-mode)
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-header t
        lsp-ui-imenu t
        lsp-ui-doc-include-signature t
        lsp-ui-doc-show-with-cursor t
        lsp-ui-doc-position 'top
        lsp-ui-doc-side 'right
        lsp-ui-doc-delay 0.5
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-show-hover t
        lsp-ui-sideline-show-symbol t
        lsp-ui-peek-always-show t
        lsp-ui-sideline-delay 0.05))

(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
(use-nix-package lsp-treemacs :commands lsp-treemacs-errors-list)


;; (use-package ccls
;;   :ensure t
;;   :config
;;   (setq ccls-sem-highlight-method 'font-lock)
;;   ;; alternatively, (setq ccls-sem-highlight-method 'overlay)
;;
;;   ;; For rainbow semantic highlighting
;;   (ccls-use-default-rainbow-sem-highlight)
;;   :hook ((c-mode c++-mode objc-mode cuda-mode) .
;;          (lambda () (require 'ccls) (lsp))))


(use-nix-package treemacs-projectile :after (treemacs projectile))


(use-package dap-mode
  :defer t
  :ensure t :after lsp-mode
  :config
  (require 'dap-python)
  (require 'dap-ui)

  (setq dap-mode t)
  (setq dap-ui-mode t)
  ;; enables mouse hover support
  (setq dap-tooltip-mode t)
  ;; if it is not enabled `dap-mode' will use the minibuffer.
  (setq tooltip-mode t)
  )

;; (use-package avy
;;   :commands avy
;;   :bind
;;   ("C-c SPC" . avy-goto-char)           ;
;;   ;; ("C-c o" . avy-select-window)
;;   )
;; Yes ace is unmaintained, but it just is nicer imo
(use-package ace-jump-mode
  :commands ace-jump-mode
  :bind
  ("C-c SPC" . ace-jump-char-mode)
  ("C-c o" . ace-select-window)
  )

(use-nix-package treemacs-nerd-icons
                 :config
                 (treemacs-load-theme "nerd-icons"))

(use-package clipetty
  :ensure t
  :hook (elpaca-after-init . global-clipetty-mode))

(setq auto-save-file-name-transforms
      `((".*" "~/.emacs.d/backups/" t)))

(add-to-list 'backup-directory-alist
             (cons "." "~/.emacs.d/backups/"))
(customize-set-variable
 'tramp-backup-directory-alist backup-directory-alist)

;; (use-package eshell-follow
;;   :defer t
;;   :after eshell)

;;some jankness either I made or stole from somewhere that I have forgotten

(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end))
     (message "Copied line")
     (list (line-beginning-position) (line-beginning-position 2)))))

(defadvice kill-ring-save (after keep-transient-mark-active ())
  "Override the deactivation of the mark."
  (setq deactivate-mark nil))
(ad-activate 'kill-ring-save)

(defadvice backward-kill-word (around delete-pair activate)
  (if (eq (char-syntax (char-before)) ?\()
      (progn
        (backward-char 1)
        (save-excursion
          (forward-sexp 1)
          (delete-char -1))
        (forward-char 1)
        (append-next-kill)
        (kill-backward-chars 1))
    ad-do-it))

(defun acg/with-mark-active (&rest args)
  "Keep mark active after command. To be used as advice AFTER any
function that sets `deactivate-mark' to t."
  (setq deactivate-mark nil))

(with-eval-after-load 'newcomment
  (advice-add 'comment-or-uncomment-region :after #'acg/with-mark-active))

(setq cd2/region-command 'cd2/comment-or-uncomment-lines)

(use-package comment-dwim-2
  :bind
  ("M-;" . comment-dwim-2))

(defun kill-line-or-region ()
  "kill region if active only or kill line normally"
  (interactive)
  (if (region-active-p)
      (call-interactively 'kill-region)
    (call-interactively 'kill-line)))

(global-set-key (kbd "C-k") 'kill-line-or-region)

(defun backward-kill-region-or-word ()
  "kill region if active only or kill line normally"
  (interactive)
  (if (region-active-p)
      (call-interactively 'kill-region)
    (call-interactively 'backward-kill-word)))
(global-set-key (kbd "C-w") 'backward-kill-region-or-word)


;;ivy/counsel/swiper/setup
(use-package counsel
  :bind
  (("C-s" . swiper-isearch)
   ("C-c C-r" . ivy-resume)
   ("<f6>" . ivy-resume)
   ("M-x" . counsel-M-x)
   ("C-x C-f" . counsel-find-file)
   ("<f1> f" . counsel-describe-function)
   ("<f1> v" . counsel-describe-variable)
   ("<f1> o" . counsel-describe-symbol)
   ("<f1> l" . counsel-find-library)
   ("<f2> i" . counsel-info-lookup-symbol)
   ("<f2> u" . counsel-unicode-char)
   ("C-c g" . counsel-git)
   ("C-c j" . counsel-git-grep)
   ("C-c k" . counsel-ag)
   ("C-x l" . counsel-locate)
   ("C-S-o" . counsel-rhythmbox)
   ("C-M-j" . 'counsel-switch-buffer)
   :map minibuffer-local-map
   ("C-r" . 'counsel-minibuffer-history))
  :config
  (setq ivy-mode t)
  (setopt ivy-use-virtual-buffers t)
  (setopt enable-recursive-minibuffers t)
  (setopt ivy-toggle-fuzzy t)
  (setq ivy-initial-inputs-alist nil)
  ;; Enable this if you want `swiper' to use it:
  ;; (setopt search-default-mode #'char-fold-to-regexp)
  )



(use-package ivy-prescient
  :after counsel
  :config
  (ivy-prescient-mode 1)
  (prescient-persist-mode 1))


(use-package corfu-prescient
  :after corfu
  :config
  (corfu-prescient-mode 1))


(setq completion-preview-sort-function #'prescient-completion-sort)

;; additions from https://zzamboni.org/post/my-doom-emacs-configuration-with-commentary/
(setq kill-whole-line t)



;; nix releated
;; (use-package nix-mode
;;   :defer t
;;   :mode ("\\.nix\\'" "\\.nix.in\\'"))
;; (add-hook! 'nix-mode-hook
;;            ;; enable autocompletion with company
;;            (setq company-idle-delay 0.1))

(use-package nix-mode
  :after lsp-mode
  :ensure t
  :hook
  (nix-mode . lsp-deferred) ;; So that envrc mode will work
  :custom
  (lsp-disabled-clients '((nix-mode . nix-nil))) ;; Disable nil so that nixd will be used as lsp-server
  :config
  (setq lsp-nix-nixd-server-path "nixd"
        lsp-nix-nixd-formatting-command [ "nixfmt" ]
        lsp-nix-nixd-nixpkgs-expr "import <nixpkgs> { }"
        lsp-nix-nixd-nixos-options-expr "(builtins.getFlake \"/home/nb/nixos\").nixosConfigurations.mnd.options"
        lsp-nix-nixd-home-manager-options-expr "(builtins.getFlake \"/home/nb/nixos\").homeConfigurations.\"nb@mnd\".options"))


(use-package nix-modeline
  :after nix-mode
  :commands (nix-modeline-mode)
  :config
  (setq nix-modeline-idle-text ""))


;; git gutter from https://ianyepan.github.io/posts/emacs-git-gutter/
(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0.02))

(use-package git-gutter-fringe
  :config
  (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom)
  )


(use-package vundo
  :bind ("M-/" . vundo)
  :config
  (setq vundo-glyph-alist vundo-unicode-symbols))

(use-package direnv
  :config
  (direnv-mode))

(use-package color-identifiers-mode
  :ensure t
  :hook (elpaca-after-init . global-color-identifiers-mode))

(use-package buffer-terminator
  :ensure t
  :custom
  ;; Enable/Disable verbose mode to log buffer cleanup events
  (buffer-terminator-verbose nil)

  ;; Set the inactivity timeout (in seconds) after which buffers are considered
  ;; inactive (default is 30 minutes):
  (buffer-terminator-inactivity-timeout (* 30 60)) ; 30 minutes

  ;; Define how frequently the cleanup process should run (default is every 10
  ;; minutes):
  (buffer-terminator-interval (* 10 60)) ; 10 minutes

  :config
  (buffer-terminator-mode 1))

;; (use-package numpydoc
;;   :ensure t
;;   :bind( (:map python-mode-map
;;                ("C-c C-n" . numpydoc-generate))
;;          (:map python-ts-mode-map
;;                ("C-c C-n" . numpydoc-generate))))
(use-package numpydoc
  :ensure t
  :after python
  :bind ("C-c C-n" . numpydoc-generate))

(use-package pyvenv
  :ensure t
  :after python)

;; ELEC3020
(use-package platformio-mode
  :ensure t
  :hook (
         (c++-mode . (lambda ()
                       (lsp-deferred)
                       )
                   )))
;; (use-package ccls
;;   :hook ((c-mode c++-mode objc-mode cuda-mode) .
;;          (lambda () (require 'ccls) (lsp))))
;;

;; (use-package vterm-toggle
;;   :ensure t
;;   ;; :hook (elpaca-after-init . vterm-toggle)
;;   :bind
;;   ("C-c t" . vterm-toggle-cd)
;;
;;   :config
;;   (define-key vterm-mode-map [(control return)]   #'vterm-toggle-insert-cd)
;;   (define-key vterm-copy-mode-map [(control return)]   #'vterm-toggle-insert-cd)
;;   )

(use-package tabspaces
  ;; use this next line only if you also use straight, otherwise ignore it.
  ;; :straight (:type git :host github :repo "mclear-tools/tabspaces")
  :hook (elpaca-after-init-hook . tabspaces-mode) ;; use this only if you want the minor-mode loaded at startup.
  :commands (tabspaces-switch-or-create-workspace
             tabspaces-open-or-create-project-and-workspace)
  :custom
  (tabspaces-use-filtered-buffers-as-default t)
  (tabspaces-default-tab "Default")
  (tabspaces-remove-to-default t)
  (tabspaces-include-buffers '("*scratch*"))
  (tabspaces-initialize-project-with-todo nil)
  ;; sessions
  (tabspaces-session t)
  (tabspaces-session-auto-restore nil)
  (tab-bar-new-tab-choice "*scratch*"))
;; Filter Buffers for Consult-Buffer

(with-eval-after-load 'consult
  ;; hide full buffer list (still available with "b" prefix)
  (consult-customize consult--source-buffer :hidden t :default nil)
  ;; set consult-workspace buffer list
  (defvar consult--source-workspace
    (list :name     "Workspace Buffers"
          :narrow   ?w
          :history  'buffer-name-history
          :category 'buffer
          :state    #'consult--buffer-state
          :default  t
          :items    (lambda () (consult--buffer-query
                                :predicate #'tabspaces--local-buffer-p
                                :sort 'visibility
                                :as #'buffer-name)))

    "Set workspace buffer list for consult-buffer.")
  (add-to-list 'consult-buffer-sources 'consult--source-workspace))

(use-package simple-comment-markup
  :straight (:type git :host nil :repo "https://code.tecosaur.net/tec/simple-comment-markup.git")
  :hook (prog-mode . simple-comment-markup-mode)
  )

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode-hook . rainbow-delimiters-mode)
  )


(use-package doxymacs
  :straight (doxymacs :type git :host github :repo "pniedzielski/doxymacs")
  :hook (c-mode-common . doxymacs-mode)
  :bind (:map c-mode-base-map
              ;; Lookup documentation for the symbol at point.
              ("C-c d ?" . doxymacs-lookup)
              ;; Rescan your Doxygen tags file.
              ("C-c d r" . doxymacs-rescan-tags)
              ;; Prompt you for a Doxygen command to enter, and its
              ;; arguments.
              ("C-c d RET" . doxymacs-insert-command)
              ;; Insert a Doxygen comment for the next function.
              ("C-c d f" . doxymacs-insert-function-comment)
              ;; Insert a Doxygen comment for the current file.
              ("C-c d i" . doxymacs-insert-file-comment)
              ;; Insert a Doxygen comment for the current member.
              ("C-c d ;" . doxymacs-insert-member-comment)
              ;; Insert a blank multi-line Doxygen comment.
              ("C-c d m" . doxymacs-insert-blank-multiline-comment)
              ;; Insert a blank single-line Doxygen comment.
              ("C-c d s" . doxymacs-insert-blank-singleline-comment)
              ;; Insert a grouping comments around the current region.
              ("C-c d @" . doxymacs-insert-grouping-comments))
  :custom
  ;; Configure source code <-> Doxygen tag file <-> Doxygen HTML
  ;; documentation mapping:
  ;;   - Files in /home/me/project/foo/ have their tag file at
  ;;     http://someplace.com/doc/foo/foo.xml, and HTML documentation
  ;;     at http://someplace.com/doc/foo/.
  ;;   - Files in /home/me/project/bar/ have their tag file at
  ;;     ~/project/bar/doc/bar.xml, and HTML documentation at
  ;;     file:///home/me/project/bar/doc/.
  ;; This must be configured for Doxymacs to function!
  (doxymacs-doxygen-dirs
   '(("^/home/bones/Storage/Uniwork/.gitJankness/ELEC3020_Project/"
      "~/home/bones/Storage/Uniwork/.gitJankness/ELEC3020_Project/project.xml"
      "file::///home/bones/Storage/Uniwork/.gitJankness/ELEC3020_Project/doc/")
     )))


;;
