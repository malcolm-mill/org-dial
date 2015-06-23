;;; org-dial.el --- Provide org links to dial with the softphone
;;; application linphone

;; Copyright (C) 2011-2014  Michael Strey

;; Author: Michael Strey <mstrey@strey.biz>
;; Keywords: dial, phone, softphone, contacts, hypermedia

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

;; `org-dial.el' defines the new link type `dial' for telephone
;; numbers in contacts (refer to org-contacts). Calling this link type
;; leads to the execution of a linphone command dialing this number.

;;; Code:

(require 'org)

;; org link functions
;; dial link
(org-add-link-type "tel" 'org-dial)

(defcustom org-dial-program "linphonecsh dial "
  "Name of the softphone executable used to dial a phone number in a `tel:' link."
  :type '(string)
  :group 'org)

(defcustom org-dial-phone-key "\\(Phone.*Value\\)"
  "Regular expression for the key of a property containing a phone number.

The default is following the Google Contacts scheme of key naming, where we have for instance:

:Phone 1 - Type: Work
:Phone 1 - Value: +49 1234 5678
:Phone 2 - Type: Home
:Phone 2 - Value: +49 56781234 

Another common scheme

:MOBILE:   0043/664/123456789
:HOMEPHONE: 0043/664/123456789
:WORKPHONE: 0043/664/123456789
:PHONE: 0043/664/123456789

would be matched by the expression

':\\(MOBILE\\|.*PHONE\\):'"
  :type '(string)
  :group 'org)

(defun org-dial (phonenumber)
  "Dial the phone number. The variable phonenumber should contain only numbers, whitespaces, backslash and maybe a `+' at the beginning."
  ;; remove whitespaces from phonenumber
  (shell-command
   (concat org-dial-program (trim-phone-number phonenumber))))

(defun trim-phone-number (phonenumber)
  "Remove whitespaces from a telephone number"
  (mapconcat 'identity
             (split-string
              (mapconcat 'identity
                         (split-string phonenumber "(0)") "") "[()/ -]") ""))

(defun org-dial-from-property (&optional prop)
  "Dial a property value with org-dial.  Asks for the appropriate property key.  If point is within the property line containing the phone number, it dials immediately."
  (interactive)
  (let* ((props (org-entry-properties))
         (prop (or prop
                   (when (org-at-property-p)
                     (org-match-string-no-properties 2))
                   (org-completing-read
                    "Get property: "
                    props t)))
         (val (org-entry-get-with-inheritance prop)))
    (if val (progn
              (org-dial val))
      (message "No valid value for %s" prop))))

(provide 'org-dial)

;;; org-dial.el ends here