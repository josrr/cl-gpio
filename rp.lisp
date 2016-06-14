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
  (:import-from #:uiop
		#:directory*
		#:split-unix-namestring-directory-components))
(in-package #:gpio-driver-rp)

(defparameter *export-file* #P"/sys/class/gpio/export")
(defparameter *devices-path* #P"/sys/class/gpio/")
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

(defun cfg-pins (pinsdef)
  (mapc (lambda (pindef)
	  (destructuring-bind (pin &key (direction)) pindef
	    (let* ((pin-name (symbol-name pin))
		   (pin-number (parse-integer (subseq pin-name 4) :junk-allowed t))
		   (pin-path (merge-pathnames
			      (concatenate 'string
					   (string-downcase pin-name) "/")
			      *devices-path*)))
	      (when (and (or (eq direction :out) (eq direction :in))
			 (equal (subseq pin-name 0 4) "GPIO")
			 pin-number)
		(or (probe-file pin-path)
		    (with-open-file (export *export-file* :direction :output :if-exists :append)
		      (format export "~D" pin-number)))
		(sleep 1)
		(with-open-file (pin-direction (merge-pathnames "direction" pin-path)
					       :direction :output :if-exists :append)
		  (format pin-direction "~A~%" (string-downcase (symbol-name direction))))))))
	pinsdef)
  (when pinsdef (setf *paths* nil)))
