;;;; -*- coding: utf-8-unix; -*-
;;;; Copyright (C) 2016 José Ronquillo Rivera <josrr@ymail.com>
;;;; This file is part of cl-gpio.
;;;;
;;;; cl-gpio is free software: you can redistribute it and/or modify
;;;; it under the terms of the GNU General Public License as published by
;;;; the Free Software Foundation, either version 3 of the License, or
;;;; (at your option) any later version.
;;;;
;;;; cl-gpio is distributed in the hope that it will be useful,
;;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;; GNU General Public License for more details.
;;;;
;;;; You should have received a copy of the GNU General Public License
;;;; along with cl-gpio.  If not, see <http://www.gnu.org/licenses/>.

(in-package #:cl-user)
(defpackage #:gpio-driver-rp
  (:use #:common-lisp)
  (:export #:init-paths
	   #:cfg-pins
	   #:*paths*
	   #:*devices-path*)
  (:import-from #:cl-inotify
		#:make-inotify
		#:watch
		#:do-events
		#:unwatch
		#:next-events
		#:read-event
		#:close-inotify)
  (:import-from #:uiop
		#:file-exists-p
		#:directory-exists-p
		#:directory*
		#:split-unix-namestring-directory-components))
(in-package #:gpio-driver-rp)

(defparameter *export-file* #P"/sys/class/gpio/export")
(defparameter *devices-path* #P"/sys/devices/virtual/gpio/")
(defparameter *paths* nil)

(defun init-paths (devices-path)
  (mapcar (lambda (path)
	    (multiple-value-bind (flag path-parts)
		(split-unix-namestring-directory-components (namestring path))
	      (declare (ignore flag))
	      (let* ((pin-name (car (last path-parts)))
		     (pin-path (merge-pathnames (concatenate 'string
							     pin-name "/")
						devices-path)))
		(list (intern (string-upcase pin-name) :keyword)
		      (merge-pathnames "value" pin-path)))))
	  (directory* (merge-pathnames #P"gpio*" devices-path))))

(defun init-wait-for-path (path)
  (let ((inotify (make-inotify)))
    (watch inotify path :all-events)
    inotify))

(defun wait-for-path (inotify file)
  (loop with exists = nil
     while (null exists)
     do (do-events (event inotify)
	  (format t "event: ~S~%~%" event)
	  (setf exists t)))
  (close-inotify inotify)
  (loop while (null (probe-file file))))

(defun write-sym (path sym)
  (when (probe-file path)
    (loop while
	 (null (handler-case
		   (with-open-file (stream path :direction :output :if-exists :append)
		     (princ (string-downcase (symbol-name sym)) stream))
		 (error (c) (declare (ignore c)) nil))))))

(defun write-num (path num)
  (when (probe-file path)
    (with-open-file (stream path :direction :output :if-exists :append)
      (princ num stream))))

(defun cfg-pins (pinsdef)
  (loop for (pin &key direction) in pinsdef
     for pin-name = (symbol-name pin)
     if (and (> (length pin-name) 4)
	     (equal (subseq pin-name 0 4) "GPIO"))
     do (let ((pin-number (parse-integer (subseq pin-name 4)
					 :junk-allowed t))
	      (direction-path (merge-pathnames "direction"
					       (merge-pathnames
						(concatenate 'string
							     (string-downcase pin-name) "/")
						*devices-path*))))
	  (when (and (or (eq direction :out) (eq direction :in))
		     pin-number)
	    (when (not (probe-file direction-path))
	      (let ((inotify (init-wait-for-path *devices-path*)))
		(write-num *export-file* pin-number)
		(wait-for-path inotify direction-path)))
	    (write-sym direction-path direction))))
  (when pinsdef (setf *paths* nil)))
