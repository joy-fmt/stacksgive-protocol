;; StacksGive Protocol - Bitcoin-Secured Transparent Charity Platform
;;
;; Title: StacksGive - Decentralized Charity Protocol on Stacks Layer 2
;;
;; Summary: 
;; A revolutionary charitable giving platform that harnesses Bitcoin's security
;; through Stacks Layer 2, enabling unprecedented transparency in donation
;; management and fund utilization tracking.
;;
;; Description:
;; StacksGive transforms the charity landscape by providing a trustless,
;; transparent donation ecosystem built on Bitcoin's immutable foundation.
;; The protocol features sophisticated role-based governance, real-time fund
;; tracking, milestone-driven disbursements, and cryptographically verified
;; donation records. Designed for NGOs, humanitarian organizations, disaster
;; relief funds, and community initiatives that demand accountability and
;; donor confidence in the digital age.
;;
;; Key Features:
;; - Bitcoin-secured immutable donation records
;; - Multi-tier role-based access control (Admin/Moderator/Beneficiary)
;; - Milestone-based fund release mechanisms
;; - Real-time transparency and audit trails
;; - Gas-efficient operations on Stacks Layer 2
;; - Regulatory-compliant charitable fund management

;; CONTRACT GOVERNANCE & OWNERSHIP

(define-data-var contract-owner principal tx-sender)

;; ERROR HANDLING CONSTANTS

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-FOUND (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-BENEFICIARY-NOT-FOUND (err u104))
(define-constant ERR-UTILIZATION-NOT-FOUND (err u105))
(define-constant ERR-INVALID-INPUT (err u106))

;; ROLE-BASED ACCESS CONTROL SYSTEM

(define-constant ROLE-ADMIN u1)
(define-constant ROLE-MODERATOR u2)
(define-constant ROLE-BENEFICIARY u3)

;; CORE DATA STRUCTURES

;; User role management mapping
(define-map roles
  { user: principal }
  { role: uint }
)

;; Beneficiary registry with comprehensive tracking
(define-map beneficiaries
  { id: uint }
  {
    name: (string-utf8 50),
    description: (string-utf8 255),
    target-amount: uint,
    received-amount: uint,
    status: (string-ascii 20),
  }
)

;; Immutable donation transaction ledger
(define-map donations
  { id: uint }
  {
    donor: principal,
    beneficiary-id: uint,
    amount: uint,
    timestamp: uint,
  }
)

;; Fund utilization tracking with milestone governance
(define-map utilization
  { id: uint }
  {
    beneficiary-id: uint,
    milestone: uint,
    description: (string-utf8 255),
    amount: uint,
    status: (string-ascii 20),
  }
)

;; ATOMIC COUNTERS FOR UNIQUE IDENTIFICATION

(define-data-var beneficiary-count uint u0)
(define-data-var donation-count uint u0)
(define-data-var utilization-count uint u0)

;; UTILITY & HELPER FUNCTIONS

;; Authorization verification with role hierarchy
(define-private (is-authorized
    (user principal)
    (required-role uint)
  )
  (let ((role-data (default-to { role: u0 } (map-get? roles { user: user }))))
    (>= (get role role-data) required-role)
  )
)