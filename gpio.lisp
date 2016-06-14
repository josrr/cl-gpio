;;;;  -*- coding: utf-8-unix; -*-
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
(defpackage #:gpio
  (:use #:common-lisp)
  (:import-from #+gpio-rp
		#:gpio-driver-rp
		#+gpio-opp
		#:gpio-driver-opp
		#+gpio-null
		#:gpio-driver-null
		#:init-paths
		#:cfg-pins
		#:*paths*
		#:*devices-path*)
  (:export #:write-pin
	   #:read-pin
	   #:cfg-pins))
(in-package #:gpio)

(defun write-pin (pin value)
  (unless *paths* (setf *paths* (init-paths *devices-path*)))
  (with-open-file (pin-out (cadr (assoc pin *paths*))
			   :direction :output :if-exists :overwrite)
    (princ value pin-out)))

(defun read-pin (pin)
  (unless *paths* (setf *paths* (init-paths *devices-path*)))
  (with-open-file (pin-in (cadr (assoc pin *paths*))
			  :direction :input)
    (read-line pin-in)))
