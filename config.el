;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Jocelyn Meyron"
      user-mail-address "JocelynMeyron@eaton.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/dev/org/")
(setq org-default-notes-file (concat org-directory "tasks.org"))

;; Disable word-wrapping everywhere
(global-visual-line-mode t)

;; Increase size of the which-key buffer at the bottom
(setq which-key-allow-imprecise-window-fit nil)

;; don't put deleted strings to X11 clipboard
(setq select-enable-clipboard nil)

;; copying and pasting selected blocks in visual mode to and from X11 clipboard
(map! "S-C-c" #'clipboard-kill-ring-save)
(map! "S-C-v" #'clipboard-yank)

;; Disable projectile automatic project discovery
(setq projectile-track-known-projects-automatically nil)

;; Set default spelling dictionary
(after! ispell
  (setq ispell-dictionary "en")
  )

;; Enable bb-mode in BitBake files
(use-package! bitbake
  :config
  (setq auto-mode-alist (cons '("\\.bb$" . bitbake-mode) auto-mode-alist))
  (setq auto-mode-alist (cons '("\\.inc$" . bitbake-mode) auto-mode-alist))
  (setq auto-mode-alist (cons '("\\.bbappend$" . bitbake-mode) auto-mode-alist))
  (setq auto-mode-alist (cons '("\\.bbclass$" . bitbake-mode) auto-mode-alist))
  (setq auto-mode-alist (cons '("\\.conf$" . bitbake-mode) auto-mode-alist))
  (setq comment-start "#")
  )

;; Org-mode configuration
(after! org
  (setq org-log-done 'time)
  (setq org-todo-keywords '((sequence "TODO(t)" "INPROGRESS(i)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))
  (setq org-priority-faces '((?A :foreground "#e45649")
                             (?B :foreground "#da8548")
                             (?C :foreground "#0098dd")))
  (add-to-list 'org-capture-templates
               '("w" "Work-related Task" entry (file org-default-notes-file)
                 "* TODO %?" :empty-lines 1))
  )

;; Function to sort TODOs under headline first alphabetically and then by priority
;; see https://stackoverflow.com/questions/22231431/sort-a-mixed-list-of-headings-in-org-mode
(defun org-sort-entries-todo-alphabetical ()
  (interactive)
  ;; First sort alphabetically
  (org-sort-entries t ?a)
  ;; Then sort by TODO keyword
  (org-sort-entries t ?o)
  ;; Rotate subtree to show children
  (org-cycle)               ; SUBTREE -> FOLDED
  (org-cycle)               ; FOLDED -> CHILDREN
  )

;;; Set better priorities
(use-package! org-fancy-priorities
  :ensure t
  :hook
  (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("HIGH" "MEDIUM" "LOW"))
  )

;; helm-ctest
(map! :leader
      :desc "Run project tests"
      "p T" #'helm-ctest)

;; dap-mode
(require 'dap-cpptools)
(defun stop-debugging-mode ()
  (interactive)
  (dap-delete-all-sessions)
  (delete-other-windows)
  )

(map! :map dap-mode-map
      :leader
      :prefix ("d" . "dap")

      ;; basics
      :desc "dap debug"         "d" #'dap-debug
      :desc "dap restart"       "r" #'dap-debug-restart
      :desc "dap next"          "n" #'dap-next
      :desc "dap step in"       "i" #'dap-step-in
      :desc "dap step out"      "o" #'dap-step-out
      :desc "dap continue"      "c" #'dap-continue
      :desc "dap close"         "k" #'stop-debugging-mode

      ;; eval
      :prefix ("de" . "Eval")
      :desc "eval"                "e" #'dap-eval
      :desc "eval thing at point" "s" #'dap-eval-thing-at-point
      :desc "add expression"      "a" #'dap-ui-expressions-add
      :desc "remove expression"   "d" #'dap-ui-expressions-remove

      ;; breakpoints
      :prefix ("db" . "Breakpoint")
      :desc "dap breakpoint toggle"      "b" #'dap-breakpoint-toggle
      )

;; Utility functions
;; https://emacs.stackexchange.com/questions/13080/reloading-directory-local-variables
(defun doom/reload-dir-locals-for-current-buffer ()
  "reload dir locals for the current buffer"
  (interactive)
  (let ((enable-local-variables :all))
    (hack-dir-local-variables-non-file-buffer)))

(defun doom/reload-dir-locals-for-all-buffers-in-this-directory ()
  "For every buffer with the same `default-directory` as the
current buffer's, reload dir-locals."
  (interactive)
  (let ((dir default-directory))
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (equal default-directory dir)
          (doom/reload-dir-locals-for-current-buffer))))))

;; https://github.com/doomemacs/doomemacs/issues/5305
(defun doom/add-directory-as-project (dir)
  "Register an arbitrary directory as a project.
If DIR is not a valid project, a .project file will be created within it. This
command will throw an error if a parent of DIR is a valid project (which would
mask DIR)."
  (interactive "D")
  (let ((short-dir (abbreviate-file-name dir))
        (proj-dir (doom-project-root dir)))
    (unless (and proj-dir (file-equal-p proj-dir dir))
      (with-temp-file (doom-path dir ".project")))
    (setq proj-dir (doom-project-root dir))
    (unless (and proj-dir (file-equal-p proj-dir dir))
      (user-error "Can't add %S as a project, because %S is already a project"
                  short-dir (abbreviate-file-name proj-dir)))
    (message "%S was not a project; adding .project file to it" short-dir)
    (projectile-add-known-project dir)))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
