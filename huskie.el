;;; huskie.el --- chainsaw powered logging

;; Copyright (C) 2012  Nic Ferrier

;; Author: Nic Ferrier <nferrier@ferrier.me.uk>
;; Keywords: lisp, processes

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Make logging through processes.

;; Named after my trusty Huskavana chainsaw. How I love it.

;;; Code:

(defconst huskie/log-default-script
  "while read line ; do echo $line >> %s ; done"
  "The default script for handling logging.")

(defconst huskie/log-script-map
  (make-hash-table :test 'equal)
  "Map of lognames to scripts used for logging.

The script should have a single %s in it which should point to
any filename.")

(defconst huskie/log-default-directory
  "/tmp"
  "The default directory where log files go.")

(defun huskie-set-script (logname shell)
  "Specify that SHELL is used to log LOGNAME."
  (puthash logname shell huskie/log-script-map))

(defun huskie/make-log-process (logname &optional filename)
  "Make a log process logging through LOGNAME script.

Optionally use FILENAME as the destination.  If there is no
FILENAME then just derive one through LOGNAME.

The script for logging is either LOGNAME specific via a lookup in
`huskie/log-script-map' or the default log script
`huskie/log-default-script'."
  (let ((file
         (or filename
             (concat
              (file-name-as-directory huskie/log-default-directory)
              logname)))
        (log-name (format "*log-%s*" filename))
        (buf-name (concat " " log-name))
        (log-script
         (or (gethash logname huskie/log-script-map)
             huskie/log-default-script)))
    (start-process-shell-command
     log-name (get-buffer-create buf-name)
     (format log-script filename))))

(defun huskie-log (text logname)
  "Send TEXT to LOGNAME.

If LOGNAME does not have an existing process it is created."
  (let ((proc (or
               (get-process logname)
               (huskie/make-log-process logname))))
    (process-send-string proc text)))

(provide 'huskie)

;;; huskie.el ends here
