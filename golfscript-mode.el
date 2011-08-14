;See LICENSE

(defun gs-eval-region-pp (start end)
  "Surround current region in [ and ]` and evaluate, showing results in *golfscript output* buffer"
  (interactive (list (point) (mark)))
  (gs-eval-region start end "[" "]`"))

(defun gs-eval-region (start end &optional prefix postfix)
  "Evaluate current region and display in *golfscript output* buffer"
  (interactive
   (list (point) (mark)))
  (save-excursion
    (let ((code-file-name (make-temp-file "golfscript-mode"))
	  (output-buffer (get-buffer-create "*golfscript output*")))
      (if prefix
	  (write-region prefix nil code-file-name nil 'nomsg))
      (write-region start end code-file-name t 'nomsg)
      (if postfix
	  (write-region postfix nil code-file-name t 'nomsg))
      (pop-to-buffer output-buffer)
      (erase-buffer)
      (start-process "golfscript" output-buffer "golfscript.rb" code-file-name)
      (sleep-for 2) ; Try to wait long enough for a response... Otherwise the seek fails.
      ; Long-running golfscript processes will have to be scrolled to see output, at least in my version.
      (goto-char (point-min)))))

(defun gs-eval-buffer ()
  "Evaluate entire buffer (not file) and display in *golfscript output* buffer"
  (interactive)
  (gs-eval-region (point-min) (point-max)))

(define-derived-mode golfscript-mode fundamental-mode "Golfscript"
   "A major mode for editing Golfscript files."
; Use default syntax table and mode map
   (set (make-local-variable 'comment-start) "# ")
   (set (make-local-variable 'comment-start-skip) "#+\\s-*"))

(define-key golfscript-mode-map "\C-c`" 'gs-eval-region-pp)
(define-key golfscript-mode-map "\C-cr" 'gs-eval-region)
(define-key golfscript-mode-map "\C-c\C-c" 'gs-eval-buffer)
(define-key golfscript-mode-map "\C-c;" 'comment-region)

; No parentheses. Fundamental mode appears to cover {} and [].
(modify-syntax-entry ?\( "w" golfscript-mode-syntax-table)
(modify-syntax-entry ?\) "w" golfscript-mode-syntax-table)

; Technically, [ ] can be used out of order or not matching each other at all.
; But I'll leave the matching for the sake of the common case.
