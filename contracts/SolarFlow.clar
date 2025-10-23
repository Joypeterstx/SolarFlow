;; SolarFlow - Decentralized Solar Energy Trading Platform with Smart Grid Integration
;; A peer-to-peer marketplace for solar energy producers and consumers with IoT device connectivity
;; SECURITY FIXES APPLIED + SMART GRID INTEGRATION + DYNAMIC PRICING ALGORITHM + ERROR HANDLING FIXES + ENERGY STORAGE MARKETPLACE

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
(define-constant err-invalid-pricing-config (err u116))
(define-constant err-invalid-storage-provider (err u117))
(define-constant err-insufficient-storage-capacity (err u118))
(define-constant err-storage-provider-inactive (err u119))
(define-constant err-invalid-storage-operation (err u120))
(define-constant err-insufficient-stored-energy (err u121))

;; Dynamic pricing constants
(define-constant blocks-per-hour u6) ;; Approximately 6 blocks per hour on Stacks
(define-constant blocks-per-day u144) ;; 24 hours * 6 blocks
(define-constant peak-hours-start u48) ;; Block 48 = 8 AM (8 * 6 blocks)
(define-constant peak-hours-end u132) ;; Block 132 = 10 PM (22 * 6 blocks)
(define-constant max-price-multiplier u300) ;; 3.0x multiplier (300/100)
(define-constant min-price-multiplier u50) ;; 0.5x multiplier (50/100)
(define-constant base-multiplier u100) ;; 1.0x base (100/100)

;; Data variables
(define-data-var next-producer-id uint u1)
(define-data-var next-listing-id uint u1)
(define-data-var next-transaction-id uint u1)
(define-data-var next-device-id uint u1)
(define-data-var next-reading-id uint u1)
(define-data-var next-storage-provider-id uint u1)
(define-data-var next-storage-transaction-id uint u1)
(define-data-var platform-fee-rate uint u250) ;; 2.5% fee
(define-data-var peak-demand-multiplier uint u150) ;; 1.5x during peak hours
(define-data-var low-supply-multiplier uint u200) ;; 2.0x when supply is low
(define-data-var high-supply-multiplier uint u80) ;; 0.8x when supply is high
(define-data-var supply-threshold-low uint u1000) ;; Low supply threshold (1000 kWh)
(define-data-var supply-threshold-high uint u10000) ;; High supply threshold (10000 kWh)

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
    base-price-per-kwh: uint,
    current-price-per-kwh: uint,
    generation-date: uint,
    expiry-date: uint,
    renewable-certificate: (string-ascii 100),
    is-active: bool,
    created-at: uint,
    price-last-updated: uint
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
    carbon-offset-kg: uint,
    price-multiplier-used: uint
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

(define-map market-metrics
  { metric-type: (string-ascii 20) }
  {
    total-supply-kwh: uint,
    total-demand-24h: uint,
    active-listings-count: uint,
    average-price-per-kwh: uint,
    last-updated: uint
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

;; Energy Storage Marketplace Data Structures
(define-map storage-providers
  { storage-provider-id: uint }
  {
    owner: principal,
    provider-name: (string-ascii 100),
    location: (string-ascii 100),
    total-capacity-kwh: uint,
    available-capacity-kwh: uint,
    stored-energy-kwh: uint,
    battery-type: (string-ascii 50),
    efficiency-rate: uint,
    is-verified: bool,
    is-active: bool,
    registered-at: uint,
    total-energy-stored: uint,
    total-energy-released: uint,
    total-storage-cycles: uint
  }
)

(define-map storage-transactions
  { storage-transaction-id: uint }
  {
    storage-provider-id: uint,
    transaction-type: (string-ascii 20),
    energy-amount-kwh: uint,
    price-per-kwh: uint,
    total-amount: uint,
    buyer-or-seller: principal,
    timestamp: uint,
    price-multiplier: uint,
    is-peak-hour: bool
  }
)

(define-map storage-provider-earnings
  { storage-provider-id: uint }
  {
    total-earned: uint,
    total-spent: uint,
    net-profit: uint,
    average-buy-price: uint,
    average-sell-price: uint,
    profit-margin: uint,
    last-transaction-date: uint
  }
)

;; Contract initialization - set up initial market metrics
(map-set market-metrics { metric-type: "current" } {
  total-supply-kwh: u0,
  total-demand-24h: u0, 
  active-listings-count: u0,
  average-price-per-kwh: u0,
  last-updated: stacks-block-height
})

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

(define-read-only (get-market-metrics)
  (default-to
    { total-supply-kwh: u0, total-demand-24h: u0, active-listings-count: u0, 
      average-price-per-kwh: u0, last-updated: u0 }
    (map-get? market-metrics { metric-type: "current" })
  )
)

(define-read-only (get-storage-provider (storage-provider-id uint))
  (map-get? storage-providers { storage-provider-id: storage-provider-id })
)

(define-read-only (get-storage-transaction (storage-transaction-id uint))
  (map-get? storage-transactions { storage-transaction-id: storage-transaction-id })
)

(define-read-only (get-storage-provider-earnings (storage-provider-id uint))
  (default-to
    { total-earned: u0, total-spent: u0, net-profit: u0, average-buy-price: u0, 
      average-sell-price: u0, profit-margin: u0, last-transaction-date: u0 }
    (map-get? storage-provider-earnings { storage-provider-id: storage-provider-id })
  )
)

(define-read-only (get-platform-fee-rate)
  (var-get platform-fee-rate)
)

(define-read-only (calculate-platform-fee (amount uint))
  (let ((validated-amount (if (> amount u0) amount u0)))
    (/ (* validated-amount (var-get platform-fee-rate)) u10000)
  )
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

(define-read-only (get-next-storage-provider-id)
  (var-get next-storage-provider-id)
)

;; Dynamic pricing read-only functions
(define-read-only (is-peak-hours)
  (let ((hour-in-day (mod stacks-block-height blocks-per-day)))
    (and (>= hour-in-day peak-hours-start) (<= hour-in-day peak-hours-end))
  )
)

(define-read-only (get-supply-demand-multiplier)
  (let 
    (
      (metrics (get-market-metrics))
      (total-supply (get total-supply-kwh metrics))
      (low-threshold (var-get supply-threshold-low))
      (high-threshold (var-get supply-threshold-high))
    )
    (if (<= total-supply low-threshold)
      (var-get low-supply-multiplier)
      (if (>= total-supply high-threshold)
        (var-get high-supply-multiplier)
        base-multiplier
      )
    )
  )
)

(define-read-only (calculate-dynamic-price (base-price uint))
  (let
    (
      (validated-base-price (if (> base-price u0) base-price u1))
      (peak-multiplier (if (is-peak-hours) (var-get peak-demand-multiplier) base-multiplier))
      (supply-multiplier (get-supply-demand-multiplier))
      (raw-multiplier (/ (* peak-multiplier supply-multiplier) u100))
      (bounded-multiplier (if (> raw-multiplier max-price-multiplier)
                            max-price-multiplier
                            (if (< raw-multiplier min-price-multiplier)
                              min-price-multiplier
                              raw-multiplier)))
      (dynamic-price (/ (* validated-base-price bounded-multiplier) u100))
      (current-supply (get total-supply-kwh (get-market-metrics)))
      (supply-status (if (<= current-supply (var-get supply-threshold-low)) 
                       "low" 
                       (if (>= current-supply (var-get supply-threshold-high)) 
                         "high" 
                         "normal")))
    )
    {
      price: dynamic-price,
      multiplier: bounded-multiplier,
      is-peak: (is-peak-hours),
      supply-level: supply-status
    }
  )
)

(define-read-only (get-pricing-config)
  {
    peak-demand-multiplier: (var-get peak-demand-multiplier),
    low-supply-multiplier: (var-get low-supply-multiplier),
    high-supply-multiplier: (var-get high-supply-multiplier),
    supply-threshold-low: (var-get supply-threshold-low),
    supply-threshold-high: (var-get supply-threshold-high),
    current-is-peak: (is-peak-hours),
    current-supply-multiplier: (get-supply-demand-multiplier)
  }
)

;; Helper function to get maximum of two values
(define-private (max-uint (a uint) (b uint))
  (if (> a b) a b)
)

;; Helper function to get minimum of two values  
(define-private (min-uint (a uint) (b uint))
  (if (< a b) a b)
)

;; Initialize market metrics if not exists
(define-private (ensure-market-metrics-exist)
  (match (map-get? market-metrics { metric-type: "current" })
    existing-metrics (ok true)
    (begin
      (map-set market-metrics { metric-type: "current" } {
        total-supply-kwh: u0,
        total-demand-24h: u0,
        active-listings-count: u0,
        average-price-per-kwh: u0,
        last-updated: stacks-block-height
      })
      (ok true)
    )
  )
)

;; Market metrics update function
(define-private (update-market-metrics)
  (let
    (
      (init-result (unwrap! (ensure-market-metrics-exist) err-invalid-data))
      (current-metrics (get-market-metrics))
      (estimated-supply u5000)
      (safe-supply (max-uint estimated-supply u0))
      (updated-metrics {
        total-supply-kwh: safe-supply,
        total-demand-24h: (get total-demand-24h current-metrics),
        active-listings-count: (get active-listings-count current-metrics),
        average-price-per-kwh: (get average-price-per-kwh current-metrics),
        last-updated: stacks-block-height
      })
    )
    (map-set market-metrics { metric-type: "current" } updated-metrics)
    (ok true)
  )
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

(define-private (is-storage-provider-owner (storage-provider-id uint) (caller principal))
  (match (map-get? storage-providers { storage-provider-id: storage-provider-id })
    provider (is-eq (get owner provider) caller)
    false
  )
)

(define-private (is-valid-storage-provider (storage-provider-id uint))
  (match (map-get? storage-providers { storage-provider-id: storage-provider-id })
    provider (and (get is-verified provider) (get is-active provider))
    false
  )
)

(define-private (update-active-listings-count-safe (increment bool))
  (let
    (
      (current-metrics (get-market-metrics))
      (current-count (get active-listings-count current-metrics))
      (new-count (if increment 
                    (+ current-count u1)
                    (if (> current-count u0) (- current-count u1) u0)))
      (updated-metrics (merge current-metrics {
        active-listings-count: new-count,
        last-updated: stacks-block-height
      }))
    )
    (map-set market-metrics { metric-type: "current" } updated-metrics)
    true
  )
)

(define-private (update-producer-earnings (producer-id uint) (amount uint) (energy-sold uint))
  (let
    (
      (producer-data (unwrap! (map-get? energy-producers { producer-id: producer-id }) err-not-found))
      (current-earnings (get-producer-earnings producer-id))
      (new-total-earned (+ (get total-earned current-earnings) amount))
      (new-total-energy-sold (+ (get total-energy-sold current-earnings) energy-sold))
      (updated-earnings {
        total-earned: new-total-earned,
        total-energy-sold: new-total-energy-sold,
        active-listings: (get active-listings current-earnings),
        last-sale-date: stacks-block-height
      })
    )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (> energy-sold u0) err-invalid-amount)
    (asserts! (> producer-id u0) err-invalid-producer)
    (asserts! (< new-total-earned u1000000000000) err-invalid-data)
    (asserts! (< new-total-energy-sold u1000000000000) err-invalid-data)
    
    (map-set producer-earnings { producer-id: producer-id } updated-earnings)
    (ok true)
  )
)

(define-private (update-user-balance (user principal) (energy-amount uint) (price uint) (carbon-offset uint))
  (let
    (
      (current-balance (get-user-balance user))
      (new-available-energy (+ (get available-energy-kwh current-balance) energy-amount))
      (new-total-purchased (+ (get total-purchased current-balance) energy-amount))
      (new-total-spent (+ (get total-spent current-balance) price))
      (new-carbon-offset (+ (get carbon-offset-total current-balance) carbon-offset))
      (updated-balance {
        available-energy-kwh: new-available-energy,
        total-purchased: new-total-purchased,
        total-spent: new-total-spent,
        carbon-offset-total: new-carbon-offset
      })
    )
    (asserts! (> energy-amount u0) err-invalid-amount)
    (asserts! (> price u0) err-invalid-price)
    (asserts! (< new-available-energy u1000000000000) err-invalid-data)
    (asserts! (< new-total-purchased u1000000000000) err-invalid-data)
    (asserts! (< new-total-spent u1000000000000) err-invalid-data)
    
    (map-set user-energy-balance { user: user } updated-balance)
    (ok true)
  )
)

(define-private (update-device-summary (device-id uint) (reading-type (string-ascii 20)) (energy-amount uint))
  (let
    (
      (device-data (unwrap! (map-get? iot-devices { device-id: device-id }) err-not-found))
      (current-summary (get-device-summary device-id))
      (is-generation (is-eq reading-type "generation"))
      (days-elapsed (/ (- stacks-block-height (get registered-at device-data)) blocks-per-day))
      (safe-days (if (> days-elapsed u0) days-elapsed u1))
      (new-total-generation (if is-generation 
                               (+ (get total-generation-kwh current-summary) energy-amount)
                               (get total-generation-kwh current-summary)))
      (new-total-consumption (if is-generation
                                (get total-consumption-kwh current-summary)
                                (+ (get total-consumption-kwh current-summary) energy-amount)))
      (updated-summary {
        total-generation-kwh: new-total-generation,
        total-consumption-kwh: new-total-consumption,
        total-readings: (+ (get total-readings current-summary) u1),
        last-generation-reading: (if is-generation stacks-block-height (get last-generation-reading current-summary)),
        last-consumption-reading: (if is-generation (get last-consumption-reading current-summary) stacks-block-height),
        average-daily-generation: (/ new-total-generation safe-days)
      })
    )
    (asserts! (> energy-amount u0) err-invalid-amount)
    (asserts! (> device-id u0) err-invalid-device)
    (asserts! (or (is-eq reading-type "generation") (is-eq reading-type "consumption")) err-invalid-reading)
    (asserts! (< new-total-generation u1000000000000) err-invalid-data)
    (asserts! (< new-total-consumption u1000000000000) err-invalid-data)
    
    (map-set device-readings-summary { device-id: device-id } updated-summary)
    (ok true)
  )
)

(define-private (update-storage-provider-earnings (storage-provider-id uint) (transaction-type (string-ascii 20)) (energy-amount uint) (price-per-kwh uint))
  (let
    (
      (provider-data (unwrap! (map-get? storage-providers { storage-provider-id: storage-provider-id }) err-not-found))
      (current-earnings (get-storage-provider-earnings storage-provider-id))
      (transaction-amount (* energy-amount price-per-kwh))
      (is-buy (is-eq transaction-type "buy"))
      (new-total-earned (if is-buy (get total-earned current-earnings) (+ (get total-earned current-earnings) transaction-amount)))
      (new-total-spent (if is-buy (+ (get total-spent current-earnings) transaction-amount) (get total-spent current-earnings)))
      (safe-new-total-earned (if (> new-total-earned u0) new-total-earned u0))
      (safe-new-total-spent (if (> new-total-spent u0) new-total-spent u0))
      (new-net-profit (if (>= safe-new-total-earned safe-new-total-spent) (- safe-new-total-earned safe-new-total-spent) u0))
      (total-transactions (+ (get total-energy-stored provider-data) (get total-energy-released provider-data)))
      (safe-total-transactions (if (> total-transactions u0) total-transactions u1))
      (new-avg-buy-price (if (> (get total-energy-stored provider-data) u0)
                            (/ (get total-spent current-earnings) (get total-energy-stored provider-data))
                            u0))
      (new-avg-sell-price (if (> (get total-energy-released provider-data) u0)
                             (/ (get total-earned current-earnings) (get total-energy-released provider-data))
                             u0))
      (new-profit-margin (if (> safe-new-total-earned u0)
                            (/ (* (- safe-new-total-earned safe-new-total-spent) u100) safe-new-total-earned)
                            u0))
      (updated-earnings {
        total-earned: safe-new-total-earned,
        total-spent: safe-new-total-spent,
        net-profit: new-net-profit,
        average-buy-price: new-avg-buy-price,
        average-sell-price: new-avg-sell-price,
        profit-margin: new-profit-margin,
        last-transaction-date: stacks-block-height
      })
    )
    (asserts! (> energy-amount u0) err-invalid-amount)
    (asserts! (> price-per-kwh u0) err-invalid-price)
    (asserts! (> storage-provider-id u0) err-invalid-storage-provider)
    (asserts! (< safe-new-total-earned u1000000000000) err-invalid-data)
    (asserts! (< safe-new-total-spent u1000000000000) err-invalid-data)
    
    (map-set storage-provider-earnings { storage-provider-id: storage-provider-id } updated-earnings)
    (ok true)
  )
)

;; String validation function
(define-private (validate-string-input (input (string-ascii 100)) (min-length uint) (max-length uint))
  (let ((input-length (len input)))
    (and (>= input-length min-length) (<= input-length max-length))
  )
)

;; Pricing validation function
(define-private (validate-pricing-multiplier (multiplier uint))
  (and (>= multiplier min-price-multiplier) (<= multiplier max-price-multiplier))
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
    (asserts! (> capacity-kw u0) err-invalid-producer)
    (asserts! (< capacity-kw u1000000) err-invalid-producer)
    (asserts! (validate-string-input name u1 u100) err-invalid-producer)
    (asserts! (validate-string-input location u1 u100) err-invalid-producer)
    (asserts! (validate-string-input certification u1 u50) err-invalid-producer)
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
    (asserts! (is-producer-owner producer-id tx-sender) err-unauthorized)
    (asserts! (get is-verified producer-data) err-invalid-producer)
    (asserts! (> producer-id u0) err-invalid-producer)
    (asserts! (validate-string-input device-type u1 u50) err-invalid-device)
    (asserts! (validate-string-input device-name u1 u100) err-invalid-device)
    (asserts! (validate-string-input manufacturer u1 u100) err-invalid-device)
    (asserts! (validate-string-input model u1 u100) err-invalid-device)
    (asserts! (validate-string-input serial-number u1 u100) err-invalid-device)
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
    (asserts! (is-device-owner device-id tx-sender) err-device-unauthorized)
    (asserts! (is-valid-device device-id) err-device-not-verified)
    (asserts! (> energy-amount-kwh u0) err-invalid-reading)
    (asserts! (< energy-amount-kwh u100000) err-invalid-reading)
    (asserts! (> voltage u0) err-invalid-reading)
    (asserts! (< voltage u1000000) err-invalid-reading)
    (asserts! (> current u0) err-invalid-reading)
    (asserts! (< current u1000000) err-invalid-reading)
    (asserts! (<= power-factor u1000) err-invalid-reading)
    (asserts! (< temperature u1000) err-invalid-reading)
    (asserts! (is-none (map-get? energy-readings { reading-id: reading-id })) err-already-exists)
    
    (map-set energy-readings { reading-id: reading-id } new-reading)
    (map-set iot-devices { device-id: device-id }
      (merge device { last-reading-at: stacks-block-height }))
    (unwrap! (update-device-summary device-id "generation" energy-amount-kwh) err-invalid-data)
    
    (var-set next-reading-id (+ reading-id u1))
    (ok reading-id)
  )
)

(define-public (create-energy-listing (producer-id uint) (energy-amount-kwh uint) (base-price-per-kwh uint) (expiry-blocks uint) (renewable-certificate (string-ascii 100)))
  (let
    (
      (listing-id (var-get next-listing-id))
      (producer (unwrap! (map-get? energy-producers { producer-id: producer-id }) err-not-found))
      (current-earnings (get-producer-earnings producer-id))
      (pricing-info (calculate-dynamic-price base-price-per-kwh))
      (new-listing {
        producer-id: producer-id,
        energy-amount-kwh: energy-amount-kwh,
        base-price-per-kwh: base-price-per-kwh,
        current-price-per-kwh: (get price pricing-info),
        generation-date: stacks-block-height,
        expiry-date: (+ stacks-block-height expiry-blocks),
        renewable-certificate: renewable-certificate,
        is-active: true,
        created-at: stacks-block-height,
        price-last-updated: stacks-block-height
      })
    )
    (asserts! (is-producer-owner producer-id tx-sender) err-unauthorized)
    (asserts! (get is-verified producer) err-invalid-producer)
    (asserts! (> energy-amount-kwh u0) err-invalid-amount)
    (asserts! (< energy-amount-kwh u1000000) err-invalid-amount)
    (asserts! (> base-price-per-kwh u0) err-invalid-price)
    (asserts! (< base-price-per-kwh u1000000) err-invalid-price)
    (asserts! (> expiry-blocks u0) err-invalid-listing)
    (asserts! (< expiry-blocks u52560) err-invalid-listing)
    (asserts! (validate-string-input renewable-certificate u1 u100) err-invalid-listing)
    (asserts! (is-none (map-get? energy-listings { listing-id: listing-id })) err-already-exists)
    
    (map-set energy-listings { listing-id: listing-id } new-listing)
    (map-set producer-earnings { producer-id: producer-id }
      (merge current-earnings { 
        active-listings: (+ (get active-listings current-earnings) u1) 
      }))
    (update-active-listings-count-safe true)
    (unwrap! (update-market-metrics) err-invalid-data)
    (var-set next-listing-id (+ listing-id u1))
    (ok listing-id)
  )
)

;; Energy Storage Marketplace Functions
(define-public (register-storage-provider (provider-name (string-ascii 100)) (location (string-ascii 100)) (total-capacity-kwh uint) (battery-type (string-ascii 50)) (efficiency-rate uint))
  (let
    (
      (storage-provider-id (var-get next-storage-provider-id))
      (new-provider {
        owner: tx-sender,
        provider-name: provider-name,
        location: location,
        total-capacity-kwh: total-capacity-kwh,
        available-capacity-kwh: total-capacity-kwh,
        stored-energy-kwh: u0,
        battery-type: battery-type,
        efficiency-rate: efficiency-rate,
        is-verified: false,
        is-active: true,
        registered-at: stacks-block-height,
        total-energy-stored: u0,
        total-energy-released: u0,
        total-storage-cycles: u0
      })
    )
    (asserts! (> total-capacity-kwh u0) err-invalid-storage-provider)
    (asserts! (< total-capacity-kwh u10000000) err-invalid-storage-provider)
    (asserts! (> efficiency-rate u0) err-invalid-storage-provider)
    (asserts! (<= efficiency-rate u100) err-invalid-storage-provider)
    (asserts! (validate-string-input provider-name u1 u100) err-invalid-storage-provider)
    (asserts! (validate-string-input location u1 u100) err-invalid-storage-provider)
    (asserts! (validate-string-input battery-type u1 u50) err-invalid-storage-provider)
    (asserts! (is-none (map-get? storage-providers { storage-provider-id: storage-provider-id })) err-already-exists)
    
    (map-set storage-providers { storage-provider-id: storage-provider-id } new-provider)
    (map-set storage-provider-earnings { storage-provider-id: storage-provider-id } {
      total-earned: u0,
      total-spent: u0,
      net-profit: u0,
      average-buy-price: u0,
      average-sell-price: u0,
      profit-margin: u0,
      last-transaction-date: u0
    })
    (var-set next-storage-provider-id (+ storage-provider-id u1))
    (ok storage-provider-id)
  )
)

(define-public (verify-storage-provider (storage-provider-id uint))
  (let
    (
      (provider (unwrap! (map-get? storage-providers { storage-provider-id: storage-provider-id }) err-not-found))
    )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (> storage-provider-id u0) err-invalid-storage-provider)
    (asserts! (not (get is-verified provider)) err-already-exists)
    
    (map-set storage-providers { storage-provider-id: storage-provider-id }
      (merge provider { is-verified: true }))
    (ok true)
  )
)

(define-public (storage-buy-energy (storage-provider-id uint) (listing-id uint) (energy-amount-kwh uint))
  (let
    (
      (storage-transaction-id (var-get next-storage-transaction-id))
      (provider (unwrap! (map-get? storage-providers { storage-provider-id: storage-provider-id }) err-not-found))
      (listing (unwrap! (map-get? energy-listings { listing-id: listing-id }) err-not-found))
      (producer (unwrap! (map-get? energy-producers { producer-id: (get producer-id listing) }) err-not-found))
      (pricing-info (calculate-dynamic-price (get base-price-per-kwh listing)))
      (current-price (get price pricing-info))
      (total-cost (* energy-amount-kwh current-price))
      (platform-fee (calculate-platform-fee total-cost))
      (seller-amount (- total-cost platform-fee))
      (available-capacity (get available-capacity-kwh provider))
      (new-available-capacity (- available-capacity energy-amount-kwh))
      (new-stored-energy (+ (get stored-energy-kwh provider) energy-amount-kwh))
      (new-total-stored (+ (get total-energy-stored provider) energy-amount-kwh))
      (remaining-energy (- (get energy-amount-kwh listing) energy-amount-kwh))
      (new-transaction {
        storage-provider-id: storage-provider-id,
        transaction-type: "buy",
        energy-amount-kwh: energy-amount-kwh,
        price-per-kwh: current-price,
        total-amount: total-cost,
        buyer-or-seller: (get owner producer),
        timestamp: stacks-block-height,
        price-multiplier: (get multiplier pricing-info),
        is-peak-hour: (get is-peak pricing-info)
      })
    )
    (asserts! (is-storage-provider-owner storage-provider-id tx-sender) err-unauthorized)
    (asserts! (is-valid-storage-provider storage-provider-id) err-storage-provider-inactive)
    (asserts! (get is-active listing) err-listing-inactive)
    (asserts! (> energy-amount-kwh u0) err-invalid-amount)
    (asserts! (<= energy-amount-kwh (get energy-amount-kwh listing)) err-insufficient-energy)
    (asserts! (<= energy-amount-kwh available-capacity) err-insufficient-storage-capacity)
    (asserts! (< total-cost u1000000000000) err-invalid-data)
    (asserts! (is-none (map-get? storage-transactions { storage-transaction-id: storage-transaction-id })) err-already-exists)
    
    (map-set storage-transactions { storage-transaction-id: storage-transaction-id } new-transaction)
    (map-set storage-providers { storage-provider-id: storage-provider-id }
      (merge provider {
        available-capacity-kwh: new-available-capacity,
        stored-energy-kwh: new-stored-energy,
        total-energy-stored: new-total-stored
      }))
    (map-set energy-listings { listing-id: listing-id }
      (merge listing {
        energy-amount-kwh: remaining-energy,
        is-active: (> remaining-energy u0)
      }))
    (unwrap! (update-producer-earnings (get producer-id listing) seller-amount energy-amount-kwh) err-invalid-data)
    (unwrap! (update-storage-provider-earnings storage-provider-id "buy" energy-amount-kwh current-price) err-invalid-data)
    (var-set next-storage-transaction-id (+ storage-transaction-id u1))
    (ok storage-transaction-id)
  )
)

(define-public (storage-sell-energy (storage-provider-id uint) (energy-amount-kwh uint) (price-per-kwh uint) (expiry-blocks uint))
  (let
    (
      (listing-id (var-get next-listing-id))
      (provider (unwrap! (map-get? storage-providers { storage-provider-id: storage-provider-id }) err-not-found))
      (stored-energy (get stored-energy-kwh provider))
      (new-stored-energy (- stored-energy energy-amount-kwh))
      (new-available-capacity (+ (get available-capacity-kwh provider) energy-amount-kwh))
      (new-total-released (+ (get total-energy-released provider) energy-amount-kwh))
      (pricing-info (calculate-dynamic-price price-per-kwh))
      (new-listing {
        producer-id: storage-provider-id,
        energy-amount-kwh: energy-amount-kwh,
        base-price-per-kwh: price-per-kwh,
        current-price-per-kwh: (get price pricing-info),
        generation-date: stacks-block-height,
        expiry-date: (+ stacks-block-height expiry-blocks),
        renewable-certificate: "STORAGE-RELEASE",
        is-active: true,
        created-at: stacks-block-height,
        price-last-updated: stacks-block-height
      })
    )
    (asserts! (is-storage-provider-owner storage-provider-id tx-sender) err-unauthorized)
    (asserts! (is-valid-storage-provider storage-provider-id) err-storage-provider-inactive)
    (asserts! (> energy-amount-kwh u0) err-invalid-amount)
    (asserts! (<= energy-amount-kwh stored-energy) err-insufficient-stored-energy)
    (asserts! (> price-per-kwh u0) err-invalid-price)
    (asserts! (< price-per-kwh u1000000) err-invalid-price)
    (asserts! (> expiry-blocks u0) err-invalid-listing)
    (asserts! (< expiry-blocks u52560) err-invalid-listing)
    (asserts! (is-none (map-get? energy-listings { listing-id: listing-id })) err-already-exists)
    
    (map-set energy-listings { listing-id: listing-id } new-listing)
    (map-set storage-providers { storage-provider-id: storage-provider-id }
      (merge provider {
        stored-energy-kwh: new-stored-energy,
        available-capacity-kwh: new-available-capacity,
        total-energy-released: new-total-released
      }))
    (update-active-listings-count-safe true)
    (unwrap! (update-market-metrics) err-invalid-data)
    (var-set next-listing-id (+ listing-id u1))
    (ok listing-id)
  )
)

(define-public (purchase-energy (listing-id uint) (energy-amount-kwh uint))
  (let
    (
      (transaction-id (var-get next-transaction-id))
      (listing (unwrap! (map-get? energy-listings { listing-id: listing-id }) err-not-found))
      (producer (unwrap! (map-get? energy-producers { producer-id: (get producer-id listing) }) err-not-found))
      (pricing-info (calculate-dynamic-price (get base-price-per-kwh listing)))
      (current-price (get price pricing-info))
      (total-cost (* energy-amount-kwh current-price))
      (platform-fee (calculate-platform-fee total-cost))
      (seller-amount (- total-cost platform-fee))
      (carbon-offset (/ (* energy-amount-kwh u7) u10))
      (remaining-energy (- (get energy-amount-kwh listing) energy-amount-kwh))
      (new-transaction {
        listing-id: listing-id,
        buyer: tx-sender,
        seller: (get owner producer),
        energy-amount-kwh: energy-amount-kwh,
        total-price: total-cost,
        platform-fee: platform-fee,
        transaction-date: stacks-block-height,
        carbon-offset-kg: carbon-offset,
        price-multiplier-used: (get multiplier pricing-info)
      })
    )
    (asserts! (get is-active listing) err-listing-inactive)
    (asserts! (not (is-eq tx-sender (get owner producer))) err-cannot-buy-own-energy)
    (asserts! (> energy-amount-kwh u0) err-invalid-amount)
    (asserts! (<= energy-amount-kwh (get energy-amount-kwh listing)) err-insufficient-energy)
    (asserts! (< total-cost u1000000000000) err-invalid-data)
    (asserts! (is-none (map-get? energy-transactions { transaction-id: transaction-id })) err-already-exists)
    
    (map-set energy-transactions { transaction-id: transaction-id } new-transaction)
    (map-set energy-listings { listing-id: listing-id }
      (merge listing {
        energy-amount-kwh: remaining-energy,
        is-active: (> remaining-energy u0)
      }))
    (unwrap! (update-producer-earnings (get producer-id listing) seller-amount energy-amount-kwh) err-invalid-data)
    (unwrap! (update-user-balance tx-sender energy-amount-kwh total-cost carbon-offset) err-invalid-data)
    (var-set next-transaction-id (+ transaction-id u1))
    (ok transaction-id)
  )
)