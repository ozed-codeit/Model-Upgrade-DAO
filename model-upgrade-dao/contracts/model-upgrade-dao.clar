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

;; Data maps
(define-map proposals
    { proposal-id: uint }
    {
        proposer: principal,
        title: (string-ascii 100),
        stake-amount: uint,
        votes-for: uint,
        votes-against: uint,
        status: (string-ascii 20),
        created-at: uint
    }
)

(define-map votes
    { proposal-id: uint, voter: principal }
    { vote-amount: uint, vote-type: bool }
)

(define-map user-stakes
    { user: principal }
    { total-staked: uint }
)

;; Additional data maps for extended functionality
(define-map proposal-comments
    { proposal-id: uint, comment-id: uint }
    { commenter: principal, comment: (string-ascii 500), timestamp: uint }
)

(define-map proposal-comment-count
    { proposal-id: uint }
    { count: uint }
)

(define-map delegations
    { delegator: principal, delegate: principal }
    { amount: uint, active: bool }
)

(define-map user-reputation
    { user: principal }
    { score: uint, proposals-created: uint, votes-cast: uint }
)

(define-map proposal-milestones
    { proposal-id: uint, milestone-id: uint }
    { description: (string-ascii 200), completed: bool, reward: uint }
)