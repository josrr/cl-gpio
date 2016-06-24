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
  (:import-from #:cl-inotify
		#:make-inotify
		#:watch
		#:do-events
		#:close-inotify
		#:inotify-event-wd)
  (:export #:write-pin
	   #:read-pin
	   #:cfg-pins
	   #:do-gpio-events))
(in-package #:gpio)

(defun write-pin (pin value)
  (unless *paths* (setf *paths* (init-paths *devices-path*)))
  (let ((paths (assoc pin *paths*)))
    (when paths
      (with-open-file (pin-out (cadr paths) :direction :output :if-exists :overwrite)
	(princ value pin-out)))))

(defun read-pin (pin)
  (unless *paths* (setf *paths* (init-paths *devices-path*)))
  (let ((paths (assoc pin *paths*)))
    (when paths
      (with-open-file (pin-in (cadr paths) :direction :input)
	(values (parse-integer (read-line pin-in)))))))


(defparameter *go-on* t)

(defun do-gpio-events-int (actions every-cycle)
  (unless *paths* (setf *paths* (init-paths *devices-path*)))
  (let ((inotify (make-inotify)))
    (unwind-protect
	 (let ((pins-wds (mapcar (lambda (action)
				   (let ((paths (assoc (car action) *paths*)))
				     (when paths
				       `(,(watch inotify (cadr paths) '(:modify))
					  ,(car action)))))
				 actions)))
	   (loop while *go-on*
	      if every-cycle do (funcall every-cycle)
	      do (do-events (event inotify :blocking-p nil)
		   (let* ((pin (cadr (assoc (inotify-event-wd event) pins-wds)))
			  (action (cadr (assoc pin actions))))
		     (when action
		       (funcall action pin (read-pin pin)))))))
      (close-inotify inotify))))

(defun expand-actions (actions)
  (mapcar (lambda (action)
	    `(list ,(car action)
		   (lambda ,(caadr action)
		     ,@(cdadr action))))
	  actions))

(defmacro do-gpio-events (actions &optional every-cycle)
  `(do-gpio-events-int `(,,@(expand-actions actions)) ,every-cycle))
