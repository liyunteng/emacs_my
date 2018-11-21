;;; my-mode.el --- my-mode                           -*- lexical-binding: t; -*-

;; Copyright (C) 2017  liyunteng

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

(use-package move-text
  :ensure t
  :bind (:map my-mode-map
	      ([(control shift up)]  . move-text-up)
	      ([(control shift down)] . move-text-down)
	      ([(meta shift up)]  . move-text-up)
	      ([(meta shift down)]  . move-text-down)
	      ))

(use-package crux
  :ensure t)

(defun my/rename-file (filename &optional new-filename)
  "Rename FILENAME to NEW-FILENAME.

When NEW-FILENAME is not specified, asks user for a new name.

Also renames associated buffer (if any exists), invalidates
projectile cache when it's possible and update recentf list."
  (interactive "f")
  (when (and filename (file-exists-p filename))
    (let* ((buffer (find-buffer-visiting filename))
	   (short-name (file-name-nondirectory filename))
	   (new-name (if new-filename new-filename
		       (read-file-name
			(format "Rename %s to: " short-name)))))
      (cond ((get-buffer new-name)
	     (error "A buffer named '%s' already exists!" new-name))
	    (t
	     (let ((dir (file-name-directory new-name)))
	       (when (and (not (file-exists-p dir)) (yes-or-no-p (format "Create directory '%s'?" dir)))
		 (make-directory dir t)))
	     (rename-file filename new-name 1)
	     (when buffer
	       (kill-buffer buffer)
	       (find-file new-name))
	     (when (fboundp 'recentf-add-file)
	       (recentf-add-file new-name)
	       (recentf-remove-if-non-kept filename))
	     (when (projectile-project-p)
	       (call-interactively #'projectile-invalidate-cache))
	     (message "File '%s' successfully renamed to '%s'" short-name (file-name-nondirectory new-name)))))))

;; from magnars
(defun my/rename-current-buffer-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let* ((name (buffer-name))
         (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        ;; (error "Buffer '%s' is not visiting a file!" name)
        (rename-buffer (read-from-minibuffer "New name: " (buffer-name)))
      (let* ((dir (file-name-directory filename))
             (new-name (read-file-name "New name: " dir)))
        (cond ((get-buffer new-name)
               (error "A buffer named '%s' already exists!" new-name))
              (t
               (let ((dir (file-name-directory new-name)))
                 (when (and (not (file-exists-p dir)) (yes-or-no-p (format "Create directory '%s'?" dir)))
                   (make-directory dir t)))
               (rename-file filename new-name 1)
               (rename-buffer new-name)
               (set-visited-file-name new-name)
               (set-buffer-modified-p nil)
               (when (fboundp 'recentf-add-file)
                 (recentf-add-file new-name)
                 (recentf-remove-if-non-kept filename))
               (when (projectile-project-p)
                 (call-interactively #'projectile-invalidate-cache))
               (message "File '%s' successfully renamed to '%s'" name (file-name-nondirectory new-name))))))))

(defun my/delete-file (filename &optional ask-user)
  "Remove specified file or directory.

Also kills associated buffer (if any exists) and invalidates
projectile cache when it's possible.

FILENAME is file or directory.
When ASK-USER is non-nil, user will be asked to confirm file
removal."
  (interactive "f")
  (when (and filename (file-exists-p filename))
    (let ((buffer (find-buffer-visiting filename)))
      (when buffer
        (kill-buffer buffer)))
    (when (or (not ask-user)
              (yes-or-no-p (format "Are you sure you want to delete %s? " filename)))
      (delete-file filename)
      (when (projectile-project-p)
        (call-interactively #'projectile-invalidate-cache)))))

(defun my/delete-file-confirm (filename)
  "Remove specified file or directory after users approval.

FILENAME is deleted using `my/delete-file' function.."
  (interactive "f")
  (funcall-interactively #'my/delete-file filename t))

;; from magnars
(defun my/delete-current-buffer-file ()
  "Remove file connected to current buffer and kill buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (kill-buffer)
      (when (yes-or-no-p (format "Are you sure you want to delete %s? " filename))
        (delete-file filename t)
        (kill-buffer buffer)
        (when (projectile-project-p)
          (call-interactively #'projectile-invalidate-cache))
        (message "Deleted file %s" filename)))))

;; http://camdez.com/blog/2013/11/14/emacs-show-buffer-file-name/
(defun my/show-and-copy-buffer-filename ()
  "Show and copy the full path to the current file in the minibuffer."
  (interactive)
  ;; list-buffers-directory is the variable set in dired buffers
  (let ((file-name (or (buffer-file-name) list-buffers-directory)))
    (if file-name
        (message (kill-new file-name))
      (error "Buffer not visiting a file"))))
;;(define-key my-mode-map (kbd "C-c C-s") 'my/rotate-windows-backward)

(defun my--revert-buffer-function (ignore-auto noconfirm)
  "Revert buffer if buffer without file, or call revert-buffer--default."
  (if (buffer-file-name)
      (funcall #'revert-buffer--default ignore-auto noconfirm)
    (call-interactively major-mode)
    ))
(setq revert-buffer-function 'my--revert-buffer-function)

(defgroup my-mode nil
  "My group."
  :group 'my)

(defvar my-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c o") 'crux-open-with)
    (define-key map (kbd "C-c M-b") 'my/baidu)
    ;; (define-key map (kbd "C-c G") 'my/github)
    ;; (define-key map (kbd "C-c y") 'my/youtube)
    ;; (define-key map (kbd "C-c U") 'my/duckduckgo)
    ;; mimic popular IDEs binding, note that it doesn't work in a terminal session
    (define-key map (kbd "C-a") 'crux-move-beginning-of-line)
    (define-key map [(shift return)] 'crux-smart-open-line)
    (define-key map (kbd "M-o") 'crux-smart-open-line)
    (define-key map [(control shift return)] 'crux-smart-open-line-above)

    (define-key map (kbd "C-c n") 'crux-cleanup-buffer-or-region)
    (define-key map (kbd "C-c f")  'crux-recentf-find-file)
    (define-key map (kbd "C-M-z") 'crux-indent-defun)
    (define-key map (kbd "C-c u") 'crux-view-url)
    (define-key map (kbd "C-c e") 'crux-eval-and-replace)
    ;; (define-key map (kbd "C-c D") 'crux-delete-file-and-buffer)
    (define-key map (kbd "C-c D") 'my/delete-current-buffer-file)
    (define-key map (kbd "C-c d") 'crux-duplicate-current-line-or-region)
    (define-key map (kbd "C-c M-d") 'crux-duplicate-and-comment-current-line-or-region)
    ;; (define-key map (kbd "C-c r") 'crux-rename-buffer-and-file)
    (define-key map (kbd "C-c r") 'my/rename-current-buffer-file)
    (define-key map (kbd "C-c t") 'crux-visit-term-buffer)
    (define-key map (kbd "C-c k") 'crux-kill-other-buffers)
    (define-key map (kbd "C-c TAB") 'crux-indent-rigidly-and-copy-to-clipboard)
    (define-key map (kbd "C-c I") 'crux-find-user-init-file)
    (define-key map (kbd "C-c S") 'crux-find-shell-init-file)
    ;; (define-key map (kbd "C-c i") 'imenu-anywhere)
    (define-key map (kbd "C-c C-s") 'crux-swap-windows)
    ;; extra prefix for projectile
    (define-key map (kbd "s-p") 'projectile-command-map)
    ;; make some use of the Super key
    (define-key map (kbd "s-r") 'crux-recentf-find-file)
    (define-key map (kbd "s-j") 'crux-top-join-line)
    (define-key map (kbd "s-k") 'crux-kill-whole-line)
    (define-key map (kbd "s-m m") 'magit-status)
    (define-key map (kbd "s-m l") 'magit-log)
    (define-key map (kbd "s-m f") 'magit-log-buffer-file)
    (define-key map (kbd "s-m b") 'magit-blame)
    (define-key map (kbd "s-o") 'crux-smart-open-line-above)

    map)
  "Keymap for my mode.")

(defun my-mode-add-menu ()
  "Add a menu entry for `prelude-mode' under Tools."
  (easy-menu-add-item nil '("Tools")
                      '("MY"
                        ("Files"
                         ["Open with..." crux-open-with]
                         ["Delete file and buffer" crux-delete-file-and-buffer]
                         ["Rename buffer and file" crux-rename-buffer-and-file])

                        ("Buffers"
                         ["Clean up buffer or region" crux-cleanup-buffer-or-region]
                         ["Kill other buffers" crux-kill-other-buffers])

                        ("Editing"
                         ["Insert empty line" prelude-insert-empty-line]
                         ["Move line up" prelude-move-line-up]
                         ["Move line down" prelude-move-line-down]
                         ["Duplicate line or region" prelude-duplicate-current-line-or-region]
                         ["Indent rigidly and copy to clipboard" crux-indent-rigidly-and-copy-to-clipboard]
                         ["Insert date" crux-insert-date]
                         ["Eval and replace" crux-eval-and-replace]
                         )

                        ("Windows"
                         ["Swap windows" crux-swap-windows])

                        ("General"
                         ["Visit term buffer" crux-visit-term-buffer]
                         ["Search in Baidu" my/baidu]
                         ["View URL" crux-view-url]))
                      "Search Files (Grep)...")

  (easy-menu-add-item nil '("Tools") '("--") "Search Files (Grep)..."))

(defun my-mode-remove-menu ()
  "Remove `my-mode' menu entry."
  (easy-menu-remove-item nil '("Tools") "MY")
  (easy-menu-remove-item nil '("Tools") "--"))

(defun turn-on-my-mode ()
  "Turn on `my-mode'."
  (my-mode +1))

(defun turn-off-my-mode ()
  "Turn off `my-mode'."
  (my-mode -1))

;; define minor mode
(define-minor-mode my-mode
  "Minor mode to consolidate Emacs Prelude extensions.

\\{my-mode-map}"
  :lighter " M"
  :group 'my-mode
  :keymap my-mode-map
  (if my-mode
      ;; on start
      (my-mode-add-menu)
    ;; on stop
    (my-mode-remove-menu)))
(define-globalized-minor-mode global-my-mode my-mode turn-on-my-mode)

(global-my-mode +1)

(provide 'my-mode)
;;; my-mode.el ends here
