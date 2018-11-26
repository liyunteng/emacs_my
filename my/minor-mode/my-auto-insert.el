;;; my-auto-insert.el --- auto-insert

;; Copyright (C) 2014  liyunteng

;; Author: liyunteng <li_yunteng@163.com>
;; Keywords: lisp, autoinsert

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

(defconst gpl-license-content
  "This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.")

(defconst gpl-license (cons "GPL" gpl-license-content))
(defconst null-license (cons nil nil))
(defcustom auto-insert-license gpl-license
  "Auto insert used license."
  :type 'symbol
  :group 'my-config)
(setq auto-insert-license null-license)

(use-package autoinsert
  :commands (auto-insert auto-insert-mode)
  :init
  (auto-insert-mode t)
  (defadvice auto-insert (around check-custom-file-auto-insert activate)
    (when custom-file
      (if (not (equal (buffer-file-name)
		      custom-file))
	  ad-do-it)))
  :config
  (use-package time-stamp
    :config
    (defun my/update-time-stamp ()
      (when time-stamp-active
	(time-stamp)))
    (setq time-stamp-line-limit 15)
    (setq time-stamp-start "Last-Updated:[ \t]+\\\\?[\"<]+")
    (setq time-stamp-format "%04Y/%02m/%02d %02H:%02M:%02S %U")
    (add-hook 'write-file-functions #'my/update-time-stamp)
    )

  ;; (setq auto-insert t)
  (setq auto-insert-query nil)
  ;; (setq auto-insert-directory "~/.emacs.d/autoinsert/")
  ;; (define-auto-insert "\.c" "c-temp.c")
  (defun my-header (&optional prefix postfix)
    "My header with PREFIX and POSTFIX."
    (append
     '((goto-char (point-min)) "")
     (if prefix prefix "")
     '('(setq-local auto-insert--begin (point))
       ;; "Filename: " (file-name-nondirectory (buffer-file-name)) "\n"
       ;; "Description: " (read-string "Description: ") "\n\n"
       "Description: " (file-name-base (buffer-file-name)) "\n\n"
       ;; "Author: " user-full-name (if (search-backward "&" (line-beginning-position) t) (replace-match (capitalize (user-login-name)) t t)) " <" user-mail-address ">\n"
       (when (car auto-insert-license)
         (concat "License: " (car auto-insert-license) "\n"))
       "Copyright (C) " (format-time-string "%Y") " " (getenv "ORGANIZATION") | (concat user-full-name) "\n"
       "Last-Updated: <>\n"
       (when (cdr auto-insert-license)
         (concat "\n"(cdr auto-insert-license) "\n"))
       (comment-region auto-insert--begin (point)))
     (if postfix postfix "")
     ))

  (define-auto-insert 'sh-mode (my-header '("#!/usr/bin/bash\n")))
  (define-auto-insert 'python-mode
    (my-header '("#!/usr/bin/env python\n" "# -*- coding: utf-8 -*-\n\n")))
  (define-auto-insert 'go-mode (my-header))
  (define-auto-insert '("\\.\\([Hh]\\|hh\\|hpp\\|hxx\\|h\\+\\+\\)\\'" . "C / C++ header")
    ;; (if (version<= emacs-version "25.1.0")
    ;; 	(my-header nil
    ;; 		   '((let ((header (upcase (concat (file-name-nondirectory
    ;; 						    (file-name-sans-extension buffer-file-name))
    ;; 						   "_"
    ;; 						   (file-name-extension buffer-file-name)
    ;; 						   "_"))))
    ;; 		       (concat "#ifndef " header "\n"
    ;; 			       "#define " header "\n\n")
    ;; 		       )
    ;; 		     _"\n\n#endif"))
    ;;   (my-header))
    (my-header))
  (define-auto-insert '("\\.\\([Cc]\\|cc\\|cpp\\|cxx\\|c\\+\\+\\)\\'" . "C / C++ program")
    ;; (if (version<= emacs-version "25.1.0")
    ;; 	(my-header nil
    ;; 		   '("#include \""
    ;; 		     (let ((stem (file-name-sans-extension buffer-file-name)))
    ;; 		       (cond ((file-exists-p (concat stem ".h"))
    ;; 			      (file-name-nondirectory (concat stem ".h")))
    ;; 			     ((file-exists-p (concat stem ".hh"))
    ;; 			      (file-name-nondirectory (concat stem ".hh")))
    ;; 			     ((file-exists-p (concat stem ".hpp"))
    ;; 			      (file-name-nondirectory (concat stem ".hpp")))
    ;; 			     ((file-exists-p (concat stem ".hxx"))
    ;; 			      (file-name-nondirectory (concat stem ".hxx")))
    ;; 			     ((file-exists-p (concat stem ".h++"))
    ;; 			      (file-name-nondirectory (concat stem ".h++")))
    ;; 			     ))
    ;; 		     & ?\" | -10 "\n"))
    ;;   (my-header))
    (my-header))
  )


(provide 'my-auto-insert)
;;; my-auto-insert.el ends here
