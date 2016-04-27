# Emacs Lisp JSON-RPC Library

This is a [JSON-RPC](http://json-rpc.org/) 1.0 and 2.0 library for
Emacs Lisp. It uses the HTTP transport method.

Three functions are provided: `json-rpc-connect`, `json-rpc-close`,
and `json-rpc`.

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

The `json-rpc-1.0` and `json-rpc-2.0` functions allow for finer
control over requests, such as endpoint selection and named parameters
(JSON-RPC 2.0).
