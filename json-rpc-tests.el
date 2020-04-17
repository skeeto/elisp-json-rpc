;;; json-rpc-tests.el --- tests for json-rpc.el

;;; Commentary:

;; Runs tests against the bitcoind JSON-RPC daemon, since that's
;; ultimately the reason I wrote this library.

;;; Code:

(require 'ert)
(require 'json-rpc)

(defvar json-rpc-password "password"
  "Password for accessing the bitcoind daemon JSON-API for testing.")

(when (condition-case nil
	  (prog1 t
	    (delete-process (make-network-process :name "test-port"
						  :host 'local
						  :service 8332
						  :noquery t
						  :buffer nil
						  :stop t)))
	(file-error nil))
  (ert-deftest json-rpc-bitcoind ()
    (json-rpc-with-connection
	(bitcoind "localhost" 8332 "bitcoinrpc" json-rpc-password)
      (should (> (json-rpc bitcoind "getblockcount") 285030))
      (should (>= (json-rpc bitcoind "getbalance") 0.0))
      (should-error (json-rpc "bogusmethod" 1 2 3)))))

(ert-deftest json-rpc-incomplete-response ()
  (insert "HTTP/1.1 200 OK\r\n"
          "Content-Length: 10\r\n")
  (should-not (json-rpc--content-finished-p)))

(ert-deftest json-rpc-wait ()
  (cl-letf (((symbol-function 'json-rpc-live-p)
	     (lambda (&rest _args) t))
	    ((symbol-function 'process-buffer)
	     (lambda (&rest _args) (current-buffer))))
    (let ((json-rpc-poll-max-seconds 1)
	  (json-rpc-poll-seconds 0.2))
      (should-error (json-rpc-wait (json-rpc--create :process nil))
		    :type 'json-rpc-error))))

(provide 'json-rpc-tests)

;;; json-rpc-tests.el ends here
