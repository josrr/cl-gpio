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
(defpackage #:gpio-driver-opp
  (:use #:common-lisp)
  (:export #:init-paths
	   #:cfg-pins
	   #:*paths*
	   #:*devices-path*)
  (:import-from #:uiop
		#:directory*
		#:split-unix-namestring-directory-components))
(in-package #:gpio-driver-opp)

(defparameter *devices-path* #P"/sys/class/gpio_sw/")
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
		(list (intern pin-name :keyword)
		      (merge-pathnames "data" pin-path)
		      (merge-pathnames "cfg" pin-path)
		      (merge-pathnames "pull" pin-path)))))
	  (directory* (merge-pathnames #P"*" devices-path))))

(defun cfg-pins (pinsdef)
  (unless *paths* (setf *paths* (init-paths *devices-path*)))
  (mapc (lambda (pindef)
	  (destructuring-bind (pin &key direction pull) pindef
	    (let* ((pin-paths (assoc pin *paths*))
		   (pin-cfg-path (caddr pin-paths))
		   (pin-pull-path (cadddr pin-paths)))
	      (when (and pin-cfg-path
			 (or (eq direction :out) (eq direction :in))
			 (probe-file pin-cfg-path))
		(with-open-file (out pin-cfg-path :direction :output :if-exists :append)
		  (princ (if (eq direction :out) 1 0) out)))
	      (when (and pin-pull-path
			 (or (eq pull :up) (eq pull :down))
			 (probe-file pin-pull-path))
		(with-open-file (out pin-pull-path :direction :output :if-exists :append)
		  (princ (if (eq pull :up) 1 0) out))))))
	pinsdef))
