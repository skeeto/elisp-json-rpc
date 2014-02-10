# Emacs Lisp JSON-RPC Library

## Usage

```el
;; Establish a connection to bitcoind:
(setf bitcoind (json-rpc-connect "localhost" 8332 "bitcoinrpc" "mypassword"))

(json-rpc bitcoind "getblockcount")
;; => 285031

(json-rpc bitcoind "setgenerate" t 3)
;; => nil

(json-rpc bitcoind "bogusmethod")
;; signals (json-rpc-error :message "Method not found" :code -32601)
```
