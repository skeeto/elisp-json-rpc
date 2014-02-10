# Emacs Lisp JSON-RPC Library

## Usage

```el
;; Establish a connection to bitcoind:
(setf rpc (json-rpc-connect "localhost" 8332 "bitcoinrpc" "mypassword"))

(json-rpc-request rpc "getblockcount")
;; => 285031

(json-rpc-request rpc "setgenerate" t 3)
;; => nil

(json-rpc-request foo "bogusmethod")
;; signals (json-rpc-error :message "Method not found" :code -32601)
```
