(load "~/quicklisp/setup.lisp")
(ql:quickload "split-sequence")

; concatenate a list of numbers
; not used here because only 2 numbers are concatenated at a time
(defun concat-nums (nums)
   (parse-integer (reduce #'(lambda (a b) (concatenate 'string a b))
      (mapcar #'write-to-string nums)))
)

; add, multiply or concat the next number to the current set of results to get the next set of results
; if lhss is '(1 2 3) and rhs is 4
; result is '(5 6 7 4 8 12)
; possible optimisation is to remove numbers greater than answer
(defun next-step (lhss rhs)
   (let* (
      (adding (lambda (x) (+ x rhs)))
      (muling (lambda (x) (* x rhs)))
      (rs (write-to-string rhs))
      (cating (lambda (x) (parse-integer (concatenate 'string (write-to-string x) rs))))
   )
      (union (union (mapcar adding lhss) (mapcar muling lhss)) (mapcar cating lhss))
   )
)

; for the first number, lhss is not a list, so that case must be handled
(defun next-step-safe (lhss rhs)
   (if (listp lhss) ; check if lhss is a list
      (next-step lhss rhs)
      (next-step (cons lhss nil) rhs)
   )
)

; get the list of possible results from list of nums
(defun possible-results (nums)
   (reduce #'next-step-safe nums)
)

; check if answer can be obtained from list nums by addition or multiplication
(defun answer-in-result (answer nums)
   (member answer (possible-results nums))
)

; if line is ok, return the result of the equation so that we can sum it later
(defun is-line-ok (line)
   (let* ( ; let* evaluates variable one by one, instead of concurrently
      (top-splat (split-sequence:split-sequence #\: line)) ; split by ':'
      (answer (parse-integer (first top-splat)))*
      (nums (mapcar #'parse-integer (split-sequence:split-sequence #\SPACE
         (string-trim " " (second top-splat))))) ; split numbers into list
   )
      (if (answer-in-result answer nums) answer 0)
   )
)

(setq sum 0)
(let ((infile (open (car *args*) :if-does-not-exist nil)))
   (when infile
      (loop for line = (read-line infile nil) while line do
         (setq sum (+ sum (is-line-ok line))))
      (close infile)
   )
)
(print sum)