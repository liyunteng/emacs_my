;;; my-smartparens.el --- my smartparnes             -*- lexical-binding: t; -*-

;; Copyright (C) 2016  liyunteng

;; Author: liyunteng <li_yunteng@163.com>
;; Keywords: lisp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(use-package smartparens
  :ensure t
  :commands (smartparens-mode
             smartparens-strict-mode
             smartparens-global-mode
             smartparens-global-strict-mode)

  :init
  (add-hook 'prog-mode-hook 'turn-on-smartparens-mode)
  (show-smartparens-global-mode +1)

  :config
  (setq sp-show-pair-delay 0.2
        ;; sp-show-pair-from-inside t
        sp-cancel-autoskip-on-backward-movement t
        sp-highlight-pair-overlay t
        sp-highlight-wrap-overlay t
        sp-highlight-wrap-tag-overlay t)
  (setq sp-base-key-bindings 'smartparens
        sp-autoskip-closing-pair 'always-end
        sp-hybrid-kill-entire-symbol nil
        blink-matching-paren nil)
  (setq sp-escape-quotes-after-insert nil)

  (require 'smartparens-config)
  ;; (sp-use-paredit-bindings)
  (sp-use-smartparens-bindings)
  (diminish 'smartparens-mode
            '(" sp" (:eval (if smartparens-strict-mode "/s"))))

  (defun my--conditionally-enable-smartparens-mode ()
    "Enable `smartparens-mode' in the minibuffer, during `eval-expression'."
    (if (or (eq this-command 'eval-expression)
            (eq this-command 'pp-eval-expression)
            (eq this-command 'eldoc-eval-expression)
            (eq this-command 'helm-eval-expression)
            (eq this-command 'edebug-eval-expression)
            (eq this-command 'debugger-eval-expression))
        (smartparens-mode)))
  (add-hook 'minibuffer-setup-hook 'my--conditionally-enable-smartparens-mode)

  (defun my--smartparens-pair-newline-and-indent (id action context)
    (save-excursion
      (newline-and-indent))
    (indent-according-to-mode))

  (defun my--smartparens-post-handler (&rest _ignored)
    (just-one-space)
    (save-excursion (insert "# ")))


  (sp-with-modes '(web-mode)
    (sp-local-pair "%" "%"
                   :unless '(sp-in-string-p)
                   :post-handlers '(("[d1]" "SPC"))))

  (sp-with-modes '(minibuffer-inactive-mode eldoc-in-minibuffer-mode)
    (sp-local-pair "'" nil :actions nil))

  (sp-pair "{" "}"
           :unless '(sp-in-comment-p sp-in-string-p)
           :post-handlers
           '(:add (my--smartparens-pair-newline-and-indent "RET" newline-and-indent)))
  (sp-pair "(" ")"
           :unless '(sp-in-comment-p sp-in-string-p)
           :post-handlers
           '(:add (my--smartparens-pair-newline-and-indent "RET" newline-and-indent)))
  (sp-pair "[" "]"
           :unless '(sp-in-comment-p sp-in-string-p)
           :post-handlers
           '(:add (my--smartparens-pair-newline-and-indent "RET" newline-and-indent)))


  ;; (define-key smartparens-mode-map (kbd ")") 'my/smart-closing-parenthesis)
  ;; (define-key smartparens-mode-map (kbd "C-M-p") 'sp-previous-sexp)
  (define-key smartparens-mode-map (kbd "C-M-a") nil)
  (define-key smartparens-mode-map (kbd "C-M-e") nil)
  ;; (define-key smartparens-mode-map (kbd "C-w") 'sp-backward-kill-word)
  (define-key smartparens-mode-map (kbd "C-M-<backspace>") 'my/backward-kill-to-indentation)
  (define-key smartparens-mode-map (kbd "M-S") 'sp-split-sexp)
  (define-key smartparens-mode-map (kbd "M-D") 'sp-splice-sexp)
  ;; (define-key smartparens-mode-map [remap backward-delete-char] 'sp-backward-delete-char)
  ;; (define-key smartparens-mode-map [remap backward-kill-word] 'sp-backward-kill-word)
  ;; (define-key smartparens-mode-map [remap backward-kill-sexp] 'sp-backward-kill-sexp)
  )


(provide 'my-smartparens)
;;; my-smartparens.el ends here
