;;; json-rpc-tests.el --- tests for json-rpc.el

;;; Commentary:

;; Runs tests against the bitcoind JSON-RPC daemon, since that's
;; ultimately the reason I wrote this library.

;;; Code:

(require 'ert)
(require 'json-rpc)

(defvar json-rpc-password "password"
  "Password for accessing the bitcoind daemon JSON-API for testing.")

(ert-deftest json-rpc-bitcoind ()
  (json-rpc-with-connection
      (bitcoind "localhost" 8332 "bitcoinrpc" json-rpc-password)
    (should (> (json-rpc bitcoind "getblockcount") 285030))
    (should (>= (json-rpc bitcoind "getbalance") 0.0))
    (should-error (json-rpc "bogusmethod" 1 2 3))))

(provide 'json-rpc-tests)

;;; json-rpc-tests.el ends here
