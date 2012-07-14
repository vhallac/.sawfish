(bind-keys global-keymap
           "W-S-Left"  'pack-window-left
           "W-S-Right" 'pack-window-right
           "W-S-Up"    'pack-window-up
           "W-S-Down"  'pack-window-down
           "W-v"       'maximize-fill-window-vertically-toggle
           "W-h"       'maximize-fill-window-horizontally-toggle)

(require 'iswitch-window)
(bind-keys global-keymap "W-s" 'iswitch-window)

;; TODO: Think a little bit more about this.
;; (defun dump-selections ()
;;   "Send the stored selections to the current window"
;;   (type-in (mapconcat identity (reverse (or (x-get-selection 'CLIPBOARD)
;;                                             (x-get-selection 'PRIMARY))))
;;            (input-focus)))

;; Paste using keyboard. Unfortunately, it doesn't work for emacs and xterm.
;; TODO: Find something better - maybe something that will paste by inserting
;; characters.
;; (require 'keyboard-paste)
;; (bind-keys global-keymap
;;            "W-Return" 'keyboard-paste
;;            "W-BS"     'clear-selection)

(require 'focus-by-direction)
(defvar dir-focus-keymap
  (bind-keys (make-keymap)
             "w" 'focus-north
             "s" 'focus-south
             "a" 'focus-west
             "d" 'focus-east))
(bind-keys global-keymap
           "W-f" 'dir-focus-keymap)

(require 'alignr)
(defvar alignr-move-keymap
  (bind-keys (make-keymap)
             "a" 'alignr-move-window-left
             "d" 'alignr-move-window-right
             "w" 'alignr-move-window-up
             "s" 'alignr-move-window-down))
(defvar alignr-grow-keymap
  (bind-keys (make-keymap)
             "a" 'alignr-grow-window-on-left
             "d" 'alignr-grow-window-on-right
             "w" 'alignr-grow-window-on-up
             "s" 'alignr-grow-window-on-down))
(defvar alignr-shrink-keymap
  (bind-keys (make-keymap)
             "a" 'alignr-shrink-window-from-left
             "d" 'alignr-shrink-window-from-right
             "w" 'alignr-shrink-window-from-up
             "s" 'alignr-shrink-window-from-down))
(bind-keys global-keymap
           "W-m" 'alignr-move-keymap)
(bind-keys global-keymap
           "W-." 'alignr-grow-keymap)
(bind-keys global-keymap
           "W-," 'alignr-shrink-keymap)
