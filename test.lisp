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

(ql:quickload "cl-gpio" :verbose t)
(ql:quickload "swank" :verbose t)

(swank:create-server :style :fd-handler :dont-close t)

(defun update-swank ()
  "Grabs SWANK connections and tells it to handle requests.
    Call this every loop in the main loop of your program"
  (let ((connection (or swank::*emacs-connection*
			(swank::default-connection))))
    (when connection
      (swank::handle-requests connection t))))

;; orange pi plus
(gpio:cfg-pins '((:pg7 :direction :out)
		 (:pg8 :direction :in)))
(gpio:write-pin :pg7 1)
(gpio:read-pin :pg8)
(gpio:write-pin :|normal_led| 1)


;; raspberry pi
(gpio:cfg-pins '((:gpio4 :direction :out)
		 (:gpio5 :direction :out)))

(gpio:do-gpio-events
    ((:gpio4 ((pin value) (format t "~S ~D~%" pin value)))
     (:gpio5))
  #'update-swank)
