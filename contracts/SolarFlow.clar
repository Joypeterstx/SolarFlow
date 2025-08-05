;; SolarFlow - Decentralized Solar Energy Trading Platform with Smart Grid Integration
;; A peer-to-peer marketplace for solar energy producers and consumers with IoT device connectivity
;; SECURITY FIXES APPLIED + SMART GRID INTEGRATION

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
(define-constant err-invalid-device (err u112))
(define-constant err-device-not-verified (err u113))
(define-constant err-invalid-reading (err u114))
(define-constant err-device-unauthorized (err u115))

;; Data variables
(define-data-var next-producer-id uint u1)
(define-data-var next-listing-id uint u1)
(define-data-var next-transaction-id uint u1)
(define-data-var next-device-id uint u1)
(define-data-var next-reading-id uint u1)
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

;; Smart Grid IoT Integration Data Structures
(define-map iot-devices
  { device-id: uint }
  {
    owner: principal,
    producer-id: uint,
    device-type: (string-ascii 50),
    device-name: (string-ascii 100),
    manufacturer: (string-ascii 100),
    model: (string-ascii 100),
    serial-number: (string-ascii 100),
    is-verified: bool,
    is-active: bool,
    registered-at: uint,
    last-reading-at: uint
  }
)

(define-map energy-readings
  { reading-id: uint }
  {
    device-id: uint,
    reading-type: (string-ascii 20),
    energy-amount-kwh: uint,
    timestamp: uint,
    voltage: uint,
    current: uint,
    power-factor: uint,
    temperature: uint,
    recorded-at: uint
  }
)

(define-map device-readings-summary
  { device-id: uint }
  {
    total-generation-kwh: uint,
    total-consumption-kwh: uint,
    total-readings: uint,
    last-generation-reading: uint,
    last-consumption-reading: uint,
    average-daily-generation: uint
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

(define-read-only (get-iot-device (device-id uint))
  (map-get? iot-devices { device-id: device-id })
)

(define-read-only (get-energy-reading (reading-id uint))
  (map-get? energy-readings { reading-id: reading-id })
)

(define-read-only (get-device-summary (device-id uint))
  (default-to
    { total-generation-kwh: u0, total-consumption-kwh: u0, total-readings: u0, 
      last-generation-reading: u0, last-consumption-reading: u0, average-daily-generation: u0 }
    (map-get? device-readings-summary { device-id: device-id })
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

(define-read-only (get-next-device-id)
  (var-get next-device-id)
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

(define-private (is-device-owner (device-id uint) (caller principal))
  (match (map-get? iot-devices { device-id: device-id })
    device (is-eq (get owner device) caller)
    false
  )
)

(define-private (is-valid-device (device-id uint))
  (match (map-get? iot-devices { device-id: device-id })
    device (and (get is-verified device) (get is-active device))
    false
  )
)

;; Updated producer earnings function with proper validation
(define-private (update-producer-earnings (producer-id uint) (amount uint) (energy-sold uint))
  (let
    (
      (producer-data (unwrap! (map-get? energy-producers { producer-id: producer-id }) err-not-found))
      (current-earnings (get-producer-earnings producer-id))
      (updated-earnings {
        total-earned: (+ (get total-earned current-earnings) amount),
        total-energy-sold: (+ (get total-energy-sold current-earnings) energy-sold),
        active-listings: (get active-listings current-earnings),
        last-sale-date: stacks-block-height
      })
    )
    ;; Validate inputs
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (> energy-sold u0) err-invalid-amount)
    ;; Prevent overflow by checking reasonable limits
    (asserts! (< (get total-earned updated-earnings) u1000000000000) err-invalid-data)
    (asserts! (< (get total-energy-sold updated-earnings) u1000000000000) err-invalid-data)
    
    (map-set producer-earnings { producer-id: producer-id } updated-earnings)
    (ok true)
  )
)

;; Updated user balance function with proper validation
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

;; IoT device data summary update function
(define-private (update-device-summary (device-id uint) (reading-type (string-ascii 20)) (energy-amount uint))
  (let
    (
      (device-data (unwrap! (map-get? iot-devices { device-id: device-id }) err-not-found))
      (current-summary (get-device-summary device-id))
      (is-generation (is-eq reading-type "generation"))
      (days-elapsed (/ (- stacks-block-height (get registered-at device-data)) u144))
      (safe-days (if (> days-elapsed u0) days-elapsed u1))
      (updated-summary 
        (if is-generation
          {
            total-generation-kwh: (+ (get total-generation-kwh current-summary) energy-amount),
            total-consumption-kwh: (get total-consumption-kwh current-summary),
            total-readings: (+ (get total-readings current-summary) u1),
            last-generation-reading: stacks-block-height,
            last-consumption-reading: (get last-consumption-reading current-summary),
            average-daily-generation: (/ (+ (get total-generation-kwh current-summary) energy-amount) safe-days)
          }
          {
            total-generation-kwh: (get total-generation-kwh current-summary),
            total-consumption-kwh: (+ (get total-consumption-kwh current-summary) energy-amount),
            total-readings: (+ (get total-readings current-summary) u1),
            last-generation-reading: (get last-generation-reading current-summary),
            last-consumption-reading: stacks-block-height,
            average-daily-generation: (get average-daily-generation current-summary)
          }
        )
      )
    )
    ;; Validate inputs
    (asserts! (> energy-amount u0) err-invalid-amount)
    (asserts! (or (is-eq reading-type "generation") (is-eq reading-type "consumption")) err-invalid-reading)
    ;; Prevent overflow
    (asserts! (< (get total-generation-kwh updated-summary) u1000000000000) err-invalid-data)
    (asserts! (< (get total-consumption-kwh updated-summary) u1000000000000) err-invalid-data)
    
    (map-set device-readings-summary { device-id: device-id } updated-summary)
    (ok true)
  )
)

;; String validation function
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
    ;; Enhanced input validation
    (asserts! (> capacity-kw u0) err-invalid-producer)
    (asserts! (< capacity-kw u1000000) err-invalid-producer)
    (asserts! (validate-string-input name u1 u100) err-invalid-producer)
    (asserts! (validate-string-input location u1 u100) err-invalid-producer)
    (asserts! (validate-string-input certification u1 u50) err-invalid-producer)
    
    ;; Validate producer-id doesn't already exist
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
    (asserts! (> producer-id u0) err-invalid-producer)
    (asserts! (not (get is-verified producer)) err-already-exists)
    
    (map-set energy-producers { producer-id: producer-id } 
      (merge producer { is-verified: true }))
    (ok true)
  )
)

;; Smart Grid IoT Functions
(define-public (register-iot-device (producer-id uint) (device-type (string-ascii 50)) (device-name (string-ascii 100)) (manufacturer (string-ascii 100)) (model (string-ascii 100)) (serial-number (string-ascii 100)))
  (let
    (
      (device-id (var-get next-device-id))
      (producer-data (unwrap! (map-get? energy-producers { producer-id: producer-id }) err-not-found))
      (new-device {
        owner: tx-sender,
        producer-id: producer-id,
        device-type: device-type,
        device-name: device-name,
        manufacturer: manufacturer,
        model: model,
        serial-number: serial-number,
        is-verified: false,
        is-active: true,
        registered-at: stacks-block-height,
        last-reading-at: u0
      })
    )
    ;; Validate inputs
    (asserts! (is-producer-owner producer-id tx-sender) err-unauthorized)
    (asserts! (get is-verified producer-data) err-invalid-producer)
    (asserts! (> producer-id u0) err-invalid-producer)
    (asserts! (validate-string-input device-type u1 u50) err-invalid-device)
    (asserts! (validate-string-input device-name u1 u100) err-invalid-device)
    (asserts! (validate-string-input manufacturer u1 u100) err-invalid-device)
    (asserts! (validate-string-input model u1 u100) err-invalid-device)
    (asserts! (validate-string-input serial-number u1 u100) err-invalid-device)
    
    ;; Validate device-id doesn't already exist
    (asserts! (is-none (map-get? iot-devices { device-id: device-id })) err-already-exists)
    
    (map-set iot-devices { device-id: device-id } new-device)
    (map-set device-readings-summary { device-id: device-id } {
      total-generation-kwh: u0,
      total-consumption-kwh: u0,
      total-readings: u0,
      last-generation-reading: u0,
      last-consumption-reading: u0,
      average-daily-generation: u0
    })
    (var-set next-device-id (+ device-id u1))
    (ok device-id)
  )
)

(define-public (verify-iot-device (device-id uint))
  (let
    (
      (device (unwrap! (map-get? iot-devices { device-id: device-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> device-id u0) err-invalid-device)
    (asserts! (not (get is-verified device)) err-already-exists)
    
    (map-set iot-devices { device-id: device-id } 
      (merge device { is-verified: true }))
    (ok true)
  )
)

(define-public (report-energy-generation (device-id uint) (energy-amount-kwh uint) (voltage uint) (current uint) (power-factor uint) (temperature uint))
  (let
    (
      (reading-id (var-get next-reading-id))
      (device (unwrap! (map-get? iot-devices { device-id: device-id }) err-not-found))
      (new-reading {
        device-id: device-id,
        reading-type: "generation",
        energy-amount-kwh: energy-amount-kwh,
        timestamp: stacks-block-height,
        voltage: voltage,
        current: current,
        power-factor: power-factor,
        temperature: temperature,
        recorded-at: stacks-block-height
      })
    )
    ;; Validate device and authorization
    (asserts! (is-device-owner device-id tx-sender) err-device-unauthorized)
    (asserts! (is-valid-device device-id) err-device-not-verified)
    
    ;; Validate reading data
    (asserts! (> energy-amount-kwh u0) err-invalid-reading)
    (asserts! (< energy-amount-kwh u100000) err-invalid-reading)
    (asserts! (> voltage u0) err-invalid-reading)
    (asserts! (< voltage u1000000) err-invalid-reading)
    (asserts! (> current u0) err-invalid-reading)
    (asserts! (< current u1000000) err-invalid-reading)
    (asserts! (<= power-factor u1000) err-invalid-reading)
    (asserts! (< temperature u1000) err-invalid-reading)
    
    ;; Validate reading-id doesn't already exist
    (asserts! (is-none (map-get? energy-readings { reading-id: reading-id })) err-already-exists)
    
    ;; Record the reading
    (map-set energy-readings { reading-id: reading-id } new-reading)
    
    ;; Update device last reading time
    (map-set iot-devices { device-id: device-id }
      (merge device { last-reading-at: stacks-block-height }))
    
    ;; Update device summary
    (try! (update-device-summary device-id "generation" energy-amount-kwh))
    
    (var-set next-reading-id (+ reading-id u1))
    (ok reading-id)
  )
)

(define-public (report-energy-consumption (device-id uint) (energy-amount-kwh uint) (voltage uint) (current uint) (power-factor uint) (temperature uint))
  (let
    (
      (reading-id (var-get next-reading-id))
      (device (unwrap! (map-get? iot-devices { device-id: device-id }) err-not-found))
      (new-reading {
        device-id: device-id,
        reading-type: "consumption",
        energy-amount-kwh: energy-amount-kwh,
        timestamp: stacks-block-height,
        voltage: voltage,
        current: current,
        power-factor: power-factor,
        temperature: temperature,
        recorded-at: stacks-block-height
      })
    )
    ;; Validate device and authorization
    (asserts! (is-device-owner device-id tx-sender) err-device-unauthorized)
    (asserts! (is-valid-device device-id) err-device-not-verified)
    
    ;; Validate reading data
    (asserts! (> energy-amount-kwh u0) err-invalid-reading)
    (asserts! (< energy-amount-kwh u100000) err-invalid-reading)
    (asserts! (> voltage u0) err-invalid-reading)
    (asserts! (< voltage u1000000) err-invalid-reading)
    (asserts! (> current u0) err-invalid-reading)
    (asserts! (< current u1000000) err-invalid-reading)
    (asserts! (<= power-factor u1000) err-invalid-reading)
    (asserts! (< temperature u1000) err-invalid-reading)
    
    ;; Validate reading-id doesn't already exist
    (asserts! (is-none (map-get? energy-readings { reading-id: reading-id })) err-already-exists)
    
    ;; Record the reading
    (map-set energy-readings { reading-id: reading-id } new-reading)
    
    ;; Update device last reading time
    (map-set iot-devices { device-id: device-id }
      (merge device { last-reading-at: stacks-block-height }))
    
    ;; Update device summary
    (try! (update-device-summary device-id "consumption" energy-amount-kwh))
    
    (var-set next-reading-id (+ reading-id u1))
    (ok reading-id)
  )
)

;; Existing energy trading functions
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
    ;; Enhanced input validation
    (asserts! (is-producer-owner producer-id tx-sender) err-unauthorized)
    (asserts! (get is-verified producer) err-invalid-producer)
    (asserts! (> energy-amount-kwh u0) err-invalid-listing)
    (asserts! (< energy-amount-kwh u10000000) err-invalid-listing)
    (asserts! (> price-per-kwh u0) err-invalid-price)
    (asserts! (< price-per-kwh u10000000) err-invalid-price)
    (asserts! (> expiry-blocks u0) err-invalid-listing)
    (asserts! (< expiry-blocks u52560) err-invalid-listing)
    (asserts! (validate-string-input renewable-certificate u1 u100) err-invalid-listing)
    
    ;; Validate listing-id doesn't already exist
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
      (carbon-offset-kg (/ energy-amount-kwh u2))
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
    ;; Enhanced validation
    (asserts! (> listing-id u0) err-not-found)
    (asserts! (get is-active listing) err-listing-inactive)
    (asserts! (< stacks-block-height (get expiry-date listing)) err-invalid-listing)
    (asserts! (<= energy-amount-kwh (get energy-amount-kwh listing)) err-insufficient-energy)
    (asserts! (> energy-amount-kwh u0) err-invalid-amount)
    (asserts! (< energy-amount-kwh u10000000) err-invalid-amount)
    (asserts! (not (is-eq tx-sender (get owner producer))) err-cannot-buy-own-energy)
    
    ;; Validate transaction amounts
    (asserts! (> total-price u0) err-invalid-price)
    (asserts! (< total-price u1000000000000) err-invalid-price)
    (asserts! (>= seller-amount u0) err-invalid-price)
    
    ;; Validate transaction-id doesn't already exist
    (asserts! (is-none (map-get? energy-transactions { transaction-id: transaction-id })) err-already-exists)
    
    ;; Transfer STX from buyer to seller
    (try! (stx-transfer? seller-amount tx-sender (get owner producer)))
    
    ;; Transfer platform fee to contract owner
    (try! (stx-transfer? platform-fee tx-sender contract-owner))
    
    ;; Update listing
    (if (is-eq energy-amount-kwh (get energy-amount-kwh listing))
      (map-set energy-listings { listing-id: listing-id } 
        (merge listing { is-active: false }))
      (map-set energy-listings { listing-id: listing-id } 
        (merge listing { energy-amount-kwh: (- (get energy-amount-kwh listing) energy-amount-kwh) }))
    )
    
    ;; Record transaction
    (map-set energy-transactions { transaction-id: transaction-id } new-transaction)
    
    ;; Update producer earnings
    (try! (update-producer-earnings (get producer-id listing) seller-amount energy-amount-kwh))
    
    ;; Update buyer balance
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
    ;; Enhanced validation
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
    (asserts! (<= new-fee-rate u1000) err-invalid-price)
    (asserts! (>= new-fee-rate u0) err-invalid-price)
    (var-set platform-fee-rate new-fee-rate)
    (ok true)
  )
)