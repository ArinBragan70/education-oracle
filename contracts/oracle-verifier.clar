;; Oracle Verifier Contract
;; Verifies claims and signatures related to oracle data submissions

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-signature (err u104))
(define-constant err-claim-expired (err u105))
(define-constant err-claim-not-verified (err u106))
(define-constant err-invalid-data (err u107))

;; Data Variables
(define-data-var admin principal contract-owner)
(define-data-var claim-nonce uint u0)
(define-data-var verification-threshold uint u1)

;; Data Maps
(define-map authorized-providers principal bool)
(define-map oracle-claims
  uint
  {
    provider: principal,
    data-hash: (buff 32),
    signature: (buff 65),
    timestamp: uint,
    verified: bool,
    verifier: (optional principal),
    expiry: uint,
    claim-type: (string-ascii 50),
    metadata: (string-utf8 256)
  }
)

(define-map provider-claims principal (list 100 uint))
(define-map claim-verifications uint (list 10 principal))
(define-map data-hash-to-claim (buff 32) uint)

;; Authorization Functions

(define-public (add-authorized-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) err-owner-only)
    (ok (map-set authorized-providers provider true))
  )
)

(define-public (remove-authorized-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) err-owner-only)
    (ok (map-delete authorized-providers provider))
  )
)

(define-read-only (is-authorized-provider (provider principal))
  (default-to false (map-get? authorized-providers provider))
)

;; Claim Submission Functions

(define-public (submit-claim 
  (data-hash (buff 32))
  (signature (buff 65))
  (expiry uint)
  (claim-type (string-ascii 50))
  (metadata (string-utf8 256))
)
  (let
    (
      (claim-id (var-get claim-nonce))
      (provider tx-sender)
      (current-time stacks-block-height)
    )
    (asserts! (is-authorized-provider provider) err-unauthorized)
    (asserts! (is-none (map-get? data-hash-to-claim data-hash)) err-already-exists)
    (asserts! (> expiry current-time) err-claim-expired)
    (asserts! (> (len data-hash) u0) err-invalid-data)
    
    (map-set oracle-claims claim-id {
      provider: provider,
      data-hash: data-hash,
      signature: signature,
      timestamp: current-time,
      verified: false,
      verifier: none,
      expiry: expiry,
      claim-type: claim-type,
      metadata: metadata
    })
    
    (map-set data-hash-to-claim data-hash claim-id)
    (map-set provider-claims provider 
      (unwrap! (as-max-len? 
        (append (default-to (list) (map-get? provider-claims provider)) claim-id) 
        u100) 
      err-invalid-data)
    )
    
    (var-set claim-nonce (+ claim-id u1))
    (ok claim-id)
  )
)

(define-public (verify-claim (claim-id uint))
  (let
    (
      (claim (unwrap! (map-get? oracle-claims claim-id) err-not-found))
      (verifier tx-sender)
      (current-time stacks-block-height)
    )
    (asserts! (is-authorized-provider verifier) err-unauthorized)
    (asserts! (not (get verified claim)) err-already-exists)
    (asserts! (> (get expiry claim) current-time) err-claim-expired)
    
    (map-set oracle-claims claim-id 
      (merge claim { verified: true, verifier: (some verifier) })
    )
    
    (map-set claim-verifications claim-id
      (unwrap! (as-max-len?
        (append (default-to (list) (map-get? claim-verifications claim-id)) verifier)
        u10)
      err-invalid-data)
    )
    
    (ok true)
  )
)

(define-public (revoke-verification (claim-id uint))
  (let
    (
      (claim (unwrap! (map-get? oracle-claims claim-id) err-not-found))
    )
    (asserts! (is-eq tx-sender (var-get admin)) err-owner-only)
    (asserts! (get verified claim) err-claim-not-verified)
    
    (map-set oracle-claims claim-id 
      (merge claim { verified: false, verifier: none })
    )
    (ok true)
  )
)

;; Query Functions

(define-read-only (get-claim (claim-id uint))
  (ok (map-get? oracle-claims claim-id))
)

(define-read-only (get-claim-by-hash (data-hash (buff 32)))
  (match (map-get? data-hash-to-claim data-hash)
    claim-id (ok (map-get? oracle-claims claim-id))
    (ok none)
  )
)

(define-read-only (get-provider-claims (provider principal))
  (ok (map-get? provider-claims provider))
)

(define-read-only (get-claim-verifications (claim-id uint))
  (ok (map-get? claim-verifications claim-id))
)

(define-read-only (is-claim-verified (claim-id uint))
  (match (map-get? oracle-claims claim-id)
    claim (ok (get verified claim))
    (ok false)
  )
)

(define-read-only (is-claim-expired (claim-id uint))
  (match (map-get? oracle-claims claim-id)
    claim (ok (< (get expiry claim) stacks-block-height))
    err-not-found
  )
)

(define-read-only (get-claim-count)
  (ok (var-get claim-nonce))
)

;; Admin Functions

(define-public (set-verification-threshold (new-threshold uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) err-owner-only)
    (ok (var-set verification-threshold new-threshold))
  )
)

(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) err-owner-only)
    (ok (var-set admin new-admin))
  )
)

(define-read-only (get-admin)
  (ok (var-get admin))
)

(define-read-only (get-verification-threshold)
  (ok (var-get verification-threshold))
)

;; Initialize contract owner as authorized provider
(map-set authorized-providers contract-owner true)

;; title: oracle-verifier
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps
;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

