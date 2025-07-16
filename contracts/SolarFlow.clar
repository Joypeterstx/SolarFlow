;; SolarFlow - Decentralized Solar Energy Trading Platform
;; A peer-to-peer marketplace for solar energy producers and consumers
;; SECURITY FIXES APPLIED

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-invalid-producer (err u102))
(define-constant err-invalid-listing (err u103))
(define-constant err-already-exists (err u104))
(define-constant err-insufficient-energy (err u105))
(define-constant err-unauthorized (err u106))
(define-constant err-invalid-price (err u107))
(define-constant err-invalid-amount (err u108))
(define-constant err-listing-inactive (err u109))
(define-constant err-cannot-buy-own-energy (err u110))
(define-constant err-invalid-data (err u111))

;; Data variables
(define-data-var next-producer-id uint u1)
(define-data-var next-listing-id uint u1)
(define-data-var next-transaction-id uint u1)
(define-data-var platform-fee-rate uint u250) ;; 2.5% fee

;; Data structures
(define-map energy-producers
  { producer-id: uint }
  {
    owner: principal,
    name: (string-ascii 100),
    location: (string-ascii 100),
    capacity-kw: uint,
    certification: (string-ascii 50),
    is-verified: bool,
    total-energy-sold: uint,
    reputation-score: uint,
    registered-at: uint
  }
)

(define-map energy-listings
  { listing-id: uint }
  {
    producer-id: uint,
    energy-amount-kwh: uint,
    price-per-kwh: uint,
    generation-date: uint,
    expiry-date: uint,
    renewable-certificate: (string-ascii 100),
    is-active: bool,
    created-at: uint
  }
)

(define-map energy-transactions
  { transaction-id: uint }
  {
    listing-id: uint,
    buyer: principal,
    seller: principal,
    energy-amount-kwh: uint,
    total-price: uint,
    platform-fee: uint,
    transaction-date: uint,
    carbon-offset-kg: uint
  }
)

(define-map user-energy-balance
  { user: principal }
  {
    available-energy-kwh: uint,
    total-purchased: uint,
    total-spent: uint,
    carbon-offset-total: uint
  }
)

(define-map producer-earnings
  { producer-id: uint }
  {
    total-earned: uint,
    total-energy-sold: uint,
    active-listings: uint,
    last-sale-date: uint
  }
)

;; Read-only functions
(define-read-only (get-producer (producer-id uint))
  (map-get? energy-producers { producer-id: producer-id })
)

(define-read-only (get-listing (listing-id uint))
  (map-get? energy-listings { listing-id: listing-id })
)

(define-read-only (get-transaction (transaction-id uint))
  (map-get? energy-transactions { transaction-id: transaction-id })
)

(define-read-only (get-user-balance (user principal))
  (default-to 
    { available-energy-kwh: u0, total-purchased: u0, total-spent: u0, carbon-offset-total: u0 }
    (map-get? user-energy-balance { user: user })
  )
)

(define-read-only (get-producer-earnings (producer-id uint))
  (default-to 
    { total-earned: u0, total-energy-sold: u0, active-listings: u0, last-sale-date: u0 }
    (map-get? producer-earnings { producer-id: producer-id })
  )
)

(define-read-only (get-platform-fee-rate)
  (var-get platform-fee-rate)
)

(define-read-only (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee-rate)) u10000)
)

(define-read-only (get-next-producer-id)
  (var-get next-producer-id)
)

(define-read-only (get-next-listing-id)
  (var-get next-listing-id)
)

;; Private functions
(define-private (is-valid-producer (producer-id uint))
  (match (map-get? energy-producers { producer-id: producer-id })
    producer (get is-verified producer)
    false
  )
)

(define-private (is-producer-owner (producer-id uint) (caller principal))
  (match (map-get? energy-producers { producer-id: producer-id })
    producer (is-eq (get owner producer) caller)
    false
  )
)

;; SECURITY FIX: Added input validation for producer earnings update
(define-private (update-producer-earnings (producer-id uint) (amount uint) (energy-sold uint))
  (let
    (
      (current-earnings (get-producer-earnings producer-id))
      (updated-earnings {
        total-earned: (+ (get total-earned current-earnings) amount),
        total-energy-sold: (+ (get total-energy-sold current-earnings) energy-sold),
        active-listings: (get active-listings current-earnings),
        last-sale-date: stacks-block-height
      })
    )
    ;; Validate that producer exists and amounts are reasonable
    (asserts! (is-some (map-get? energy-producers { producer-id: producer-id })) err-not-found)
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (> energy-sold u0) err-invalid-amount)
    ;; Prevent overflow by checking reasonable limits
    (asserts! (< (get total-earned updated-earnings) u1000000000000) err-invalid-data)
    (asserts! (< (get total-energy-sold updated-earnings) u1000000000000) err-invalid-data)
    
    (map-set producer-earnings { producer-id: producer-id } updated-earnings)
    (ok true)
  )
)

;; SECURITY FIX: Added input validation for user balance update
(define-private (update-user-balance (user principal) (energy-amount uint) (price uint) (carbon-offset uint))
  (let
    (
      (current-balance (get-user-balance user))
      (updated-balance {
        available-energy-kwh: (+ (get available-energy-kwh current-balance) energy-amount),
        total-purchased: (+ (get total-purchased current-balance) energy-amount),
        total-spent: (+ (get total-spent current-balance) price),
        carbon-offset-total: (+ (get carbon-offset-total current-balance) carbon-offset)
      })
    )
    ;; Validate inputs
    (asserts! (> energy-amount u0) err-invalid-amount)
    (asserts! (> price u0) err-invalid-price)
    ;; Prevent overflow by checking reasonable limits
    (asserts! (< (get available-energy-kwh updated-balance) u1000000000000) err-invalid-data)
    (asserts! (< (get total-purchased updated-balance) u1000000000000) err-invalid-data)
    (asserts! (< (get total-spent updated-balance) u1000000000000) err-invalid-data)
    
    (map-set user-energy-balance { user: user } updated-balance)
    (ok true)
  )
)

;; SECURITY FIX: Added comprehensive input validation
(define-private (validate-string-input (input (string-ascii 100)) (min-length uint) (max-length uint))
  (let ((input-length (len input)))
    (and (>= input-length min-length) (<= input-length max-length))
  )
)

;; Public functions
(define-public (register-producer (name (string-ascii 100)) (location (string-ascii 100)) (capacity-kw uint) (certification (string-ascii 50)))
  (let
    (
      (producer-id (var-get next-producer-id))
      (new-producer {
        owner: tx-sender,
        name: name,
        location: location,
        capacity-kw: capacity-kw,
        certification: certification,
        is-verified: false,
        total-energy-sold: u0,
        reputation-score: u100,
        registered-at: stacks-block-height
      })
    )
    ;; SECURITY FIX: Enhanced input validation
    (asserts! (> capacity-kw u0) err-invalid-producer)
    (asserts! (< capacity-kw u1000000) err-invalid-producer) ;; Max 1MW capacity
    (asserts! (validate-string-input name u1 u100) err-invalid-producer)
    (asserts! (validate-string-input location u1 u100) err-invalid-producer)
    (asserts! (validate-string-input certification u1 u50) err-invalid-producer)
    
    ;; SECURITY FIX: Validate producer-id doesn't already exist
    (asserts! (is-none (map-get? energy-producers { producer-id: producer-id })) err-already-exists)
    
    (map-set energy-producers { producer-id: producer-id } new-producer)
    (map-set producer-earnings { producer-id: producer-id } {
      total-earned: u0,
      total-energy-sold: u0,
      active-listings: u0,
      last-sale-date: u0
    })
    (var-set next-producer-id (+ producer-id u1))
    (ok producer-id)
  )
)

(define-public (verify-producer (producer-id uint))
  (let
    (
      (producer (unwrap! (map-get? energy-producers { producer-id: producer-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    ;; SECURITY FIX: Additional validation
    (asserts! (> producer-id u0) err-invalid-producer)
    (asserts! (not (get is-verified producer)) err-already-exists) ;; Prevent double verification
    
    (map-set energy-producers { producer-id: producer-id } 
      (merge producer { is-verified: true }))
    (ok true)
  )
)

(define-public (create-energy-listing (producer-id uint) (energy-amount-kwh uint) (price-per-kwh uint) (expiry-blocks uint) (renewable-certificate (string-ascii 100)))
  (let
    (
      (listing-id (var-get next-listing-id))
      (producer (unwrap! (map-get? energy-producers { producer-id: producer-id }) err-not-found))
      (current-earnings (get-producer-earnings producer-id))
      (new-listing {
        producer-id: producer-id,
        energy-amount-kwh: energy-amount-kwh,
        price-per-kwh: price-per-kwh,
        generation-date: stacks-block-height,
        expiry-date: (+ stacks-block-height expiry-blocks),
        renewable-certificate: renewable-certificate,
        is-active: true,
        created-at: stacks-block-height
      })
    )
    ;; SECURITY FIX: Enhanced input validation
    (asserts! (is-producer-owner producer-id tx-sender) err-unauthorized)
    (asserts! (get is-verified producer) err-invalid-producer)
    (asserts! (> energy-amount-kwh u0) err-invalid-listing)
    (asserts! (< energy-amount-kwh u10000000) err-invalid-listing) ;; Max 10M kWh
    (asserts! (> price-per-kwh u0) err-invalid-price)
    (asserts! (< price-per-kwh u10000000) err-invalid-price) ;; Max reasonable price
    (asserts! (> expiry-blocks u0) err-invalid-listing)
    (asserts! (< expiry-blocks u52560) err-invalid-listing) ;; Max 1 year (assuming 10min blocks)
    (asserts! (validate-string-input renewable-certificate u1 u100) err-invalid-listing)
    
    ;; SECURITY FIX: Validate listing-id doesn't already exist
    (asserts! (is-none (map-get? energy-listings { listing-id: listing-id })) err-already-exists)
    
    (map-set energy-listings { listing-id: listing-id } new-listing)
    (map-set producer-earnings { producer-id: producer-id }
      (merge current-earnings { active-listings: (+ (get active-listings current-earnings) u1) }))
    (var-set next-listing-id (+ listing-id u1))
    (ok listing-id)
  )
)

(define-public (purchase-energy (listing-id uint) (energy-amount-kwh uint))
  (let
    (
      (listing (unwrap! (map-get? energy-listings { listing-id: listing-id }) err-not-found))
      (producer (unwrap! (map-get? energy-producers { producer-id: (get producer-id listing) }) err-not-found))
      (transaction-id (var-get next-transaction-id))
      (total-price (* energy-amount-kwh (get price-per-kwh listing)))
      (platform-fee (calculate-platform-fee total-price))
      (seller-amount (- total-price platform-fee))
      (carbon-offset-kg (/ energy-amount-kwh u2)) ;; Assume 0.5kg CO2 offset per kWh
      (new-transaction {
        listing-id: listing-id,
        buyer: tx-sender,
        seller: (get owner producer),
        energy-amount-kwh: energy-amount-kwh,
        total-price: total-price,
        platform-fee: platform-fee,
        transaction-date: stacks-block-height,
        carbon-offset-kg: carbon-offset-kg
      })
    )
    ;; SECURITY FIX: Enhanced validation
    (asserts! (> listing-id u0) err-not-found)
    (asserts! (get is-active listing) err-listing-inactive)
    (asserts! (< stacks-block-height (get expiry-date listing)) err-invalid-listing)
    (asserts! (<= energy-amount-kwh (get energy-amount-kwh listing)) err-insufficient-energy)
    (asserts! (> energy-amount-kwh u0) err-invalid-amount)
    (asserts! (< energy-amount-kwh u10000000) err-invalid-amount) ;; Max purchase limit
    (asserts! (not (is-eq tx-sender (get owner producer))) err-cannot-buy-own-energy)
    
    ;; SECURITY FIX: Validate transaction amounts
    (asserts! (> total-price u0) err-invalid-price)
    (asserts! (< total-price u1000000000000) err-invalid-price) ;; Prevent overflow
    (asserts! (>= seller-amount u0) err-invalid-price)
    
    ;; SECURITY FIX: Validate transaction-id doesn't already exist
    (asserts! (is-none (map-get? energy-transactions { transaction-id: transaction-id })) err-already-exists)
    
    ;; Transfer STX from buyer to seller
    (try! (stx-transfer? seller-amount tx-sender (get owner producer)))
    
    ;; Transfer platform fee to contract owner
    (try! (stx-transfer? platform-fee tx-sender contract-owner))
    
    ;; Update listing - SECURITY FIX: Proper validation before update
    (if (is-eq energy-amount-kwh (get energy-amount-kwh listing))
      (map-set energy-listings { listing-id: listing-id } 
        (merge listing { is-active: false }))
      (map-set energy-listings { listing-id: listing-id } 
        (merge listing { energy-amount-kwh: (- (get energy-amount-kwh listing) energy-amount-kwh) }))
    )
    
    ;; Record transaction
    (map-set energy-transactions { transaction-id: transaction-id } new-transaction)
    
    ;; Update producer earnings - SECURITY FIX: Now returns result
    (try! (update-producer-earnings (get producer-id listing) seller-amount energy-amount-kwh))
    
    ;; Update buyer balance - SECURITY FIX: Now returns result
    (try! (update-user-balance tx-sender energy-amount-kwh total-price carbon-offset-kg))
    
    (var-set next-transaction-id (+ transaction-id u1))
    (ok transaction-id)
  )
)

(define-public (deactivate-listing (listing-id uint))
  (let
    (
      (listing (unwrap! (map-get? energy-listings { listing-id: listing-id }) err-not-found))
      (producer (unwrap! (map-get? energy-producers { producer-id: (get producer-id listing) }) err-not-found))
    )
    ;; SECURITY FIX: Enhanced validation
    (asserts! (> listing-id u0) err-not-found)
    (asserts! (is-eq tx-sender (get owner producer)) err-unauthorized)
    (asserts! (get is-active listing) err-listing-inactive)
    
    (map-set energy-listings { listing-id: listing-id } 
      (merge listing { is-active: false }))
    (ok true)
  )
)

(define-public (update-platform-fee (new-fee-rate uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (<= new-fee-rate u1000) err-invalid-price) ;; Max 10% fee
    (asserts! (>= new-fee-rate u0) err-invalid-price) ;; Min 0% fee
    (var-set platform-fee-rate new-fee-rate)
    (ok true)
  )
)