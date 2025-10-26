;; ModelUpgrade DAO - Community-driven AI model improvement funding
;; Users propose and vote on model upgrades with token staking

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-voted (err u102))
(define-constant err-insufficient-stake (err u103))
(define-constant err-proposal-closed (err u104))

;; Data vars
(define-data-var proposal-nonce uint u0)
(define-data-var min-stake uint u1000)