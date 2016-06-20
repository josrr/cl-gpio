;; -*- coding: utf-8-unix; -*-

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

(defsystem #:cl-gpio
  :description "GPIO library for Orange PI Plus and Raspberry Pi"
  :version "0.1"
  :author "José Miguel Ronquillo Rivera <josrr@ymail.com>"
  :license "GPLv3"
  :depends-on (#:cl-inotify)
  :serial t
  :perform (prepare-op :after (op c)
		       (cond ((probe-file #P"/sys/class/gpio_sw/") (pushnew :gpio-opp *features*))
			     ((probe-file #P"/sys/class/gpio/") (pushnew :gpio-rp *features*))
			     (t (pushnew :gpio-null *features*))))
  :components ((:module
		"gpio-drivers"
		:pathname #P"."
		:components ((:file "rp")
			     (:file "opp")
			     (:file "null")))
	       (:file "gpio")))

;;(defmethod perform :before ((op load-op) (c (eql (find-system :cl-gpio)))))

