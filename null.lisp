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
(defpackage #:gpio-driver-null
  (:use #:common-lisp)
  (:export #:init-paths
	   #:cfg-pins
	   #:*paths*
	   #:*devices-path*))
(in-package #:gpio-driver-null)

(defparameter *devices-path* nil)
(defparameter *paths* nil)

(defun init-paths (devices-path)
  (error "GPIO device not supported"))

(defun cfg-pins (pinsdef)
  (error "GPIO device not supported"))
