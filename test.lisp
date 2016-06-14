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
(ql:quickload "cl-gpio" :verbose t)
(ql:quickload "swank" :verbose t)
(ql:quickload "log4cl" :verbose t)
;; (ql:quickload "cl-fad" :verbose t)
(swank:create-server :style :fd-handler :dont-close t)

