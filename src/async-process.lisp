(defpackage :async-process
  (:use :cl)
  (:export
   :delete-process
   :process-send-input
   :process-receive-output
   :process-alive-p
   :create-process
   :process-version))
(in-package :async-process)

(pushnew (asdf:system-relative-pathname :async-process "../static/")
         cffi:*foreign-library-directories*
         :test #'uiop:pathname-equal)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defun system (cmd)
    (ignore-errors (string-right-trim '(#\Newline) (uiop:run-program cmd :output :string))))
  (defun abi-version ()
    (with-open-file (i (asdf:system-relative-pathname :async-process "../Makefile.am"))
      (loop :for line := (read-line i nil nil)
            :while line
            :for (a . b) := (uiop:split-string line :separator '(#\=))
            :when (equal a "libasync_abiversion")
            :return (first b)))))

(cffi:define-foreign-library async-process
  (:unix #.(format nil "libasyncprocess-~A-~A-~A.so"
                   (system "uname -m")
                   (system "uname")
                   (abi-version)))
  (:windows #.(format nil "libasyncprocess-~A-~A.dll"
                      (if (or #+x86-64 t)
                          "x86_64"
                          "x86")
                      (abi-version))))

(cffi:use-foreign-library async-process)

(defclass process ()
  ((process :reader process-process :initarg :process)
   (encode :accessor process-encode :initarg :encode)))

(cffi:defcfun ("cl_async_process_create" %create-process) :pointer
  (command :pointer)
  (nonblock :boolean)
  (buffer-size :unsigned-int))

(cffi:defcfun ("cl_async_process_delete" %delete-process) :void
  (process :pointer))

(cffi:defcfun ("cl_async_process_pid" %process-pid) :int
  (process :pointer))

(cffi:defcfun ("cl_async_process_send_input" %process-send-input) :void
  (process :pointer)
  (string :string))

(cffi:defcfun ("cl_async_process_receive_output" %process-receive-output) :string
  (process :pointer))

(cffi:defcfun ("cl_async_process_alive_p" %process-alive-p) :boolean
  (process :pointer))

(cffi:defcfun ("cl_async_process_version" process-version) :string)

(defun create-process (command &key nonblock (encode cffi:*default-foreign-encoding*))
  (let* ((command (uiop:ensure-list command))
         (length (length command)))
    (cffi:with-foreign-object (argv :string (1+ length))
      (loop :for i :from 0
            :for c :in command
            :do (setf (cffi:mem-aref argv :string i) c))
      (setf (cffi:mem-aref argv :string length) (cffi:null-pointer))
      (make-instance 'process
		     :process (%create-process argv nonblock (* 4 1024))
		     :encode  encode))))

(defun delete-process (process)
  (%delete-process (process-process process)))

(defun process-pid (process)
  (%process-pid (process-process process)))

(defun process-send-input (process string)
  (let ((cffi:*default-foreign-encoding* (process-encode process)))
    (%process-send-input (process-process process) string)))

(defun process-receive-output (process)
  (let ((cffi:*default-foreign-encoding* (process-encode process)))
    (%process-receive-output (process-process process))))

(defun process-alive-p (process)
  (%process-alive-p (process-process process)))
