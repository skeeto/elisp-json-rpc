;;; json-rpc.el --- JSON-RPC library -*- lexical-binding: t; -*-

;; This is free and unencumbered software released into the public domain.

;;; Commentary:

;; The two important functions are `json-rpc-connect' and
;; `json-rpc-request'. The first one returns a connection object and
;; the second one makes synchronous requests on the connection,
;; returning the result or signaling an error.

;; Here's an example using the bitcoind JSON-RPC API:

;; (setf rpc (json-rpc-connect "localhost" 8332 "bitcoinrpc" "mypassword"))
;; (json-rpc-request rpc "getblockcount")  ; => 285031
;; (json-rpc-request rpc "setgenerate" t 3)

;; TODO:
;;  * asynchronous requests
;;  * response timeout

;;; Code:

(require 'cl-lib)
(require 'json)

(cl-defstruct (json-rpc (:constructor json-rpc--create))
  "A connection to a remote JSON-RPC server."
  process host port auth id-counter)

;; Set up error condition.
(setf (get 'json-rpc-error 'error-conditions) '(json-rpc-error error)
      (get 'json-rpc-error 'error-message) "JSON-RPC error condition.")

(defun json-rpc-connect (host port &optional username password)
  "Create a JSON-RPC HTTP connection to HOST:PORT."
  (let ((auth (when (and username password)
                (base64-encode-string (format "%s:%s" username password))))
        (port-num (if (stringp port) (read port) port)))
    (json-rpc-ensure
     (json-rpc--create :host host :port port-num :auth auth :id-counter 0))))

(defun json-rpc-ensure (connection)
  "Re-establish connection to CONNECTION if needed, returning CONNECTION."
  (let ((old-process (json-rpc-process connection)))
    (if (and old-process (process-live-p old-process))
        connection
      (let* ((buffer (generate-new-buffer " *json-rpc*"))
             (host (json-rpc-host connection))
             (process (make-network-process :name (format "json-rpc-%s" host)
                                            :buffer buffer
                                            :host host
                                            :service (json-rpc-port connection)
                                            :family 'ipv4
                                            :coding '(utf-8 . utf-8))))
        (prog1 connection
          (setf (json-rpc-process connection) process))))))

(defun json-rpc-request (connection method &rest params)
  "Send request of METHOD to CONNECTION, returning result or signalling error."
  (let* ((id (cl-incf (json-rpc-id-counter connection)))
         (vparams (vconcat params))
         (request `(:jsonrpc "2.0" :method ,method :params ,vparams :id ,id))
         (auth (json-rpc-auth connection))
         (process (json-rpc-process (json-rpc-ensure connection)))
         (encoded (json-encode request)))
    (with-current-buffer (process-buffer (json-rpc-process connection))
      (erase-buffer))
    (with-temp-buffer
      (insert "GET / HTTP/1.1\r\n")
      (when auth (insert "Authorization: Basic " auth "\r\n"))
      (insert (format "Content-Length: %d" (string-bytes encoded))
              "\r\n\r\n"
              encoded)
      (process-send-region process (point-min) (point-max)))
    (json-rpc-wait connection)))

(defun json-rpc-wait (connection)
  "Wait for the response from CONNECTION and return it, or signal the error."
  (with-current-buffer (process-buffer (json-rpc-process connection))
    (cl-block nil
      (while t
        (setf (point) (point-min))
        (when (search-forward "Content-Length: " nil t)
          (let ((length (read (current-buffer))))
            (search-forward "\r\n\r\n")
            (when (<= length (- (position-bytes (point-max))
                                (position-bytes (point))))
              (let* ((json-object-type 'plist)
                     (json-key-type 'keyword)
                     (result (json-read)))
                (if (plist-get result :error)
                    (signal 'json-rpc-error (plist-get result :error))
                  (cl-return (plist-get result :result)))))))
        (accept-process-output)))))

(provide 'json-rpc)

;;; json-rpc.el ends here
