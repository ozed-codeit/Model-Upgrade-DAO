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

;; Read-only functions
(define-read-only (get-proposal (proposal-id uint))
    (map-get? proposals { proposal-id: proposal-id })
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
    (map-get? votes { proposal-id: proposal-id, voter: voter })
)

(define-read-only (get-user-stake (user principal))
    (map-get? user-stakes { user: user })
)

(define-read-only (get-min-stake)
    (ok (var-get min-stake))
)

;; Extended read-only functions
(define-read-only (get-proposal-comment (proposal-id uint) (comment-id uint))
    (map-get? proposal-comments { proposal-id: proposal-id, comment-id: comment-id })
)

(define-read-only (get-proposal-comment-count (proposal-id uint))
    (default-to { count: u0 } (map-get? proposal-comment-count { proposal-id: proposal-id }))
)

(define-read-only (get-delegation (delegator principal) (delegate principal))
    (map-get? delegations { delegator: delegator, delegate: delegate })
)

(define-read-only (get-user-reputation (user principal))
    (default-to { score: u0, proposals-created: u0, votes-cast: u0 } 
        (map-get? user-reputation { user: user }))
)

(define-read-only (get-proposal-milestone (proposal-id uint) (milestone-id uint))
    (map-get? proposal-milestones { proposal-id: proposal-id, milestone-id: milestone-id })
)

(define-read-only (calculate-voting-power (user principal))
    (let
        (
            (stake (default-to { total-staked: u0 } (get-user-stake user)))
            (reputation (get-user-reputation user))
        )
        (ok (+ (get total-staked stake) (get score reputation)))
    )
)

(define-read-only (get-proposal-status (proposal-id uint))
    (let
        (
            (proposal (unwrap! (get-proposal proposal-id) err-not-found))
        )
        (ok {
            status: (get status proposal),
            votes-for: (get votes-for proposal),
            votes-against: (get votes-against proposal),
            total-votes: (+ (get votes-for proposal) (get votes-against proposal))
        })
    )
)

;; Helper functions
(define-private (is-proposal-active (proposal-id uint))
    (match (get-proposal proposal-id)
        proposal (is-eq (get status proposal) "active")
        false
    )
)

(define-private (calculate-quorum (proposal-id uint))
    (let
        (
            (proposal (unwrap-panic (get-proposal proposal-id)))
            (total-votes (+ (get votes-for proposal) (get votes-against proposal)))
        )
        (> total-votes (var-get min-stake))
    )
)