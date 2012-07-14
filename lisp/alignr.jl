(require 'rects)
(require 'maximize)

(define (make-alignr-commands)
  (define (relevant-windows window)
    (remove-if (lambda (win)
                 (or (eq win window)
                     (window-iconified-p win)
                     (not (window-appears-in-workspace-p win current-workspace))))
               (managed-windows)))

  (define (grid-points-for window orientation)
    (define selectors `((:vertical ,cadr ,cadddr)
                        (:horizontal ,car ,caddr)))
    (let ((rects (rectangles-from-windows (relevant-windows window)))
          (funcs (cdr (assq orientation selectors))))
      (unless (null funcs)
        (uniquify-list
         (nconc (mapcar (car funcs) rects)
                (mapcar (cadr funcs) rects))))))

  (define (between pos min max)
    "t if min<pos<max"
    (and (>= pos min)
         (<= pos max)))

  (define (within pos target delta)
    "t if target-delta < pos < target or target > pos > target+delta"
    (or (between pos (- target delta) target)
        (between pos target (+ target delta))))

  (define (rect-side rect side)
    (cond ((eq side ':left) rect)
          ((eq side ':right) (cddr rect))
          ((eq side ':up) (cdr rect))
          ((eq side ':down) (cdddr rect))))

  (define (get-window-side window side)
    (let ((winrect (car (rectangles-from-windows (list window)))))
      (car (rect-side winrect side))))

  (define (get-window-frame-thickness window)
    (let ((frame-size (window-frame-dimensions window))
          (window-size (window-dimensions window)))
      (cons (- (car frame-size) (car window-size))
            (- (cdr frame-size) (cdr window-size)))))

  (define (set-window-side window side position)
    (let ((winrect (car (rectangles-from-windows (list window)))))
      (setcar (rect-side winrect side) position)
      (let* ((pos (cons (car winrect) (cadr winrect)))
             (thickness (get-window-frame-thickness window))
             (size (cons (- (caddr winrect) (car winrect) (car thickness))
                         (- (cadddr winrect) (cadr winrect) (cdr thickness)))))
        (maximize-truncate-dims window size
                                (if (eq (orientation-of side) ':horizontal)
                                    'horizontal
                                  'vertical))
        (move-resize-window-to window
                               (car pos) (cdr pos)
                               (car size) (cdr size)))))

  (define (get-min-increment window orientation)
    (let ((hints (window-size-hints window)))
      (or (cdr (assq
                (if (eq orientation ':horizontal)
                    'width-inc
                  'height-inc)
                hints)) 1)))

  (define (get-coord coord-pair orientation)
    (if (eq orientation ':horizontal)
        (car coord-pair)
      (cdr coord-pair)))

  (define (set-coord! coord-pair orientation new-value)
    (if (eq orientation ':horizontal)
        (setcar coord-pair new-value)
      (setcdr coord-pair new-value)))

  (define (orientation-of direction)
    (if (memq direction '(:left :right))
        ':horizontal
      ':vertical))

  (define (move-window window dir)
    (let ((orientation (orientation-of dir))
          (window-pos-pair (window-position window)))
      (when orientation
        (let ((window-pos (get-coord window-pos-pair orientation))
              (window-size (get-coord (window-frame-dimensions window) orientation))
              (screen-size (get-coord (cons (screen-width)
                                            (screen-height)) orientation))
              (grid-points (grid-points-for window orientation)))
          (nconc grid-points (mapcar (lambda (x) (- x window-size)) grid-points))
          (define (update-window min-pos max-pos selector-func)
            (let ((candidates (remove-if (lambda (x)
                                           (or (eql x window-pos)
                                               (not (between x min-pos max-pos))))
                                         grid-points)))
              (when candidates
                (set-coord! window-pos-pair orientation
                            (apply selector-func candidates))
                (move-window-to window (car window-pos-pair) (cdr window-pos-pair)))))
          (if (memq dir '(:left :up))
              (update-window 0 window-pos #'max)
            (update-window window-pos (- screen-size window-size) #'min))))))

  (define (move-window-side window side dir)
    (let ((orientation (orientation-of dir)))
      (when (and orientation
                 (eq orientation (orientation-of side)))
        (let ((side-pos (get-window-side window side))
              (screen-size (get-coord (cons (screen-width)
                                            (screen-height)) orientation))
              (grid-points (grid-points-for window orientation)))
          (define (update-window min-pos max-pos selector-func)
            (let* ((min-increment (get-min-increment window orientation))
                   (candidates (remove-if (lambda (x)
                                            (or (within x side-pos min-increment)
                                                (not (between x min-pos max-pos))))
                                          grid-points)))
              (when candidates
                (set-window-side window side
                                 (apply selector-func candidates)))))
          (if (memq dir '(:left :up))
              (update-window 0 side-pos #'max)
            (update-window side-pos screen-size #'min))))))

  (define (current-window)
    "Obtain the current window.
This function is lifted from sawfish/wm/commands.jl"
    (let ((win (current-event-window)))
      (if (or (null win) (eq win 'root))
          (input-focus)
        win)))

  ;; Make move commands...
  (define-command 'alignr-move-window-left move-window
    #:spec (lambda () (list (current-window) ':left)))
  (define-command 'alignr-move-window-right move-window
    #:spec (lambda () (list (current-window) ':right)))
  (define-command 'alignr-move-window-up move-window
    #:spec (lambda () (list (current-window) ':up)))
  (define-command 'alignr-move-window-down move-window
    #:spec (lambda () (list (current-window) ':down)))

  ;; Make grow commands
  (define-command 'alignr-grow-window-on-left move-window-side
    #:spec (lambda () (list (current-window) ':left ':left)))
  (define-command 'alignr-grow-window-on-right move-window-side
    #:spec (lambda () (list (current-window) ':right ':right)))
  (define-command 'alignr-grow-window-on-up move-window-side
    #:spec (lambda () (list (current-window) ':up ':up)))
  (define-command 'alignr-grow-window-on-down move-window-side
    #:spec (lambda () (list (current-window) ':down ':down)))

  ;; Make shrink commands
  (define-command 'alignr-shrink-window-from-left move-window-side
    #:spec (lambda () (list (current-window) ':left ':right)))
  (define-command 'alignr-shrink-window-from-right move-window-side
    #:spec (lambda () (list (current-window) ':right ':left)))
  (define-command 'alignr-shrink-window-from-up move-window-side
    #:spec (lambda () (list (current-window) ':up ':down)))
  (define-command 'alignr-shrink-window-from-down move-window-side
    #:spec (lambda () (list (current-window) ':down ':up))))

(make-alignr-commands)
