# SolarFlow - Decentralized Solar Energy Trading Platform

A comprehensive peer-to-peer marketplace for solar energy trading built on the Stacks blockchain with intelligent dynamic pricing, smart grid IoT integration, and energy storage marketplace capabilities.

## Overview

SolarFlow enables solar energy producers to sell excess energy directly to consumers without intermediaries. The platform features real-time dynamic pricing based on supply/demand conditions and time-of-day patterns, IoT device connectivity for automated energy monitoring, and an energy storage marketplace for battery operators to optimize grid stability.

## Key Features

### 🚀 Dynamic Pricing Engine
- **Time-Based Pricing**: Automatic price adjustments during peak hours (8 AM - 10 PM)
- **Supply-Demand Balancing**: Real-time price modifications based on market availability
- **Peak Hour Multipliers**: 1.5x pricing during high-demand periods
- **Market Efficiency**: Automatic price discovery for optimal energy trading
- **Price Bounds**: Intelligent limits (0.5x - 3.0x) prevent extreme pricing fluctuations

### ⚡ Smart Grid IoT Integration
- **Device Registration**: Connect solar panels, meters, and monitoring devices
- **Real-Time Monitoring**: Track voltage, current, power factor, and temperature
- **Automated Reporting**: IoT devices report generation and consumption data
- **Device Verification**: Admin-controlled device authentication system
- **Performance Analytics**: Aggregated device statistics and daily averages

### 🔋 Energy Storage Marketplace
- **Storage Provider Registration**: Battery operators can register storage capacity
- **Buy from Grid**: Storage providers purchase energy during low-price periods
- **Sell to Grid**: Release stored energy during peak demand for profit
- **Capacity Management**: Track available capacity and stored energy levels
- **Earnings Analytics**: Monitor profit margins, buy/sell prices, and ROI

### 🌍 Core Platform Features
- **Producer Registration**: Solar energy producers register with capacity and certifications
- **Energy Listings**: Create listings with base prices that adjust dynamically
- **Transparent Trading**: Purchase energy at market-optimized prices
- **Carbon Tracking**: Automatic calculation of carbon offset benefits (0.7 kg CO₂/kWh)
- **Reputation System**: Track producer performance and transaction history
- **Platform Fees**: Configurable fee structure (default 2.5%)

## Smart Contract Functions

### Producer Management
```clarity
(register-producer 
  (name (string-ascii 100))
  (location (string-ascii 100))
  (capacity-kw uint)
  (certification (string-ascii 50)))
```
Register as a solar energy producer with verification details.

```clarity
(verify-producer (producer-id uint))
```
Admin function to verify and activate producer credentials.

```clarity
(get-producer (producer-id uint))
```
Retrieve complete producer information and statistics.

### Dynamic Energy Trading
```clarity
(create-energy-listing
  (producer-id uint)
  (energy-amount-kwh uint)
  (base-price-per-kwh uint)
  (expiry-blocks uint)
  (renewable-certificate (string-ascii 100)))
```
Create energy listing with base price that adjusts based on market conditions.

```clarity
(purchase-energy 
  (listing-id uint)
  (energy-amount-kwh uint))
```
Purchase energy at current dynamic market price with automatic platform fee calculation.

### IoT Smart Grid Integration
```clarity
(register-iot-device
  (producer-id uint)
  (device-type (string-ascii 50))
  (device-name (string-ascii 100))
  (manufacturer (string-ascii 100))
  (model (string-ascii 100))
  (serial-number (string-ascii 100)))
```
Connect IoT monitoring devices to registered producers.

```clarity
(report-energy-generation
  (device-id uint)
  (energy-amount-kwh uint)
  (voltage uint)
  (current uint)
  (power-factor uint)
  (temperature uint))
```
Report real-time energy generation data with electrical parameters.

```clarity
(verify-iot-device (device-id uint))
```
Admin verification for IoT device authentication.

### Energy Storage Marketplace
```clarity
(register-storage-provider
  (provider-name (string-ascii 100))
  (location (string-ascii 100))
  (total-capacity-kwh uint)
  (battery-type (string-ascii 50))
  (efficiency-rate uint))
```
Register as an energy storage provider with battery specifications.

```clarity
(storage-buy-energy
  (storage-provider-id uint)
  (listing-id uint)
  (energy-amount-kwh uint))
```
Purchase energy from the market to store in batteries.

```clarity
(storage-sell-energy
  (storage-provider-id uint)
  (energy-amount-kwh uint)
  (price-per-kwh uint)
  (expiry-blocks uint))
```
Release stored energy back to the market during profitable periods.

```clarity
(verify-storage-provider (storage-provider-id uint))
```
Admin verification for storage provider credentials.

### Dynamic Pricing System
```clarity
(calculate-dynamic-price (base-price uint))
```
Calculate current market price with supply/demand and time-of-day adjustments.

Returns:
```clarity
{
  price: uint,              ;; Current dynamic price
  multiplier: uint,         ;; Applied multiplier (100 = 1.0x)
  is-peak: bool,           ;; Peak hours indicator
  supply-level: string     ;; "low", "normal", or "high"
}
```

```clarity
(get-pricing-config)
```
View current pricing algorithm parameters and thresholds.

```clarity
(is-peak-hours)
```
Check if current block height falls within peak demand hours.

```clarity
(get-supply-demand-multiplier)
```
Get current supply/demand multiplier based on market conditions.

### Data Access & Analytics
```clarity
(get-listing (listing-id uint))
```
View energy listing with current dynamic pricing information.

```clarity
(get-user-balance (user principal))
```
Check user's energy holdings, purchase history, and carbon offsets.

```clarity
(get-producer-earnings (producer-id uint))
```
View producer's total earnings, energy sold, and active listings.

```clarity
(get-market-metrics)
```
Access real-time market supply, demand, and average pricing data.

```clarity
(get-device-summary (device-id uint))
```
Retrieve aggregated IoT device performance and generation statistics.

```clarity
(get-storage-provider (storage-provider-id uint))
```
View storage provider capacity, stored energy, and operational status.

```clarity
(get-storage-provider-earnings (storage-provider-id uint))
```
Access storage provider profit analytics and transaction history.

## Getting Started

### Prerequisites
- [Clarinet CLI](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for testnet/mainnet deployment
- Basic understanding of Clarity smart contracts

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/solarflow.git
cd solarflow

# Verify contract syntax
clarinet check

# Run test suite
clarinet test

# Deploy to network
clarinet deploy
```

## Dynamic Pricing Configuration

### Default Settings
- **Peak Hours**: 8 AM - 10 PM daily (blocks 48-132 of daily cycle)
- **Peak Hour Multiplier**: 1.5x base price
- **Low Supply Threshold**: 1,000 kWh (triggers 2.0x multiplier)
- **High Supply Threshold**: 10,000 kWh (triggers 0.8x multiplier)
- **Price Bounds**: 0.5x minimum, 3.0x maximum
- **Blocks Per Hour**: 6 (Stacks blockchain approximation)
- **Platform Fee**: 2.5% of transaction value

### Pricing Examples
```
Base Price: 100 STX/kWh

Scenario 1 - Peak Hours + Low Supply:
- Time Multiplier: 1.5x (peak hours)
- Supply Multiplier: 2.0x (low supply)
- Final Price: 100 × 1.5 × 2.0 = 300 STX/kWh

Scenario 2 - Off-Peak + High Supply:
- Time Multiplier: 1.0x (off-peak)
- Supply Multiplier: 0.8x (high supply)
- Final Price: 100 × 1.0 × 0.8 = 80 STX/kWh

Scenario 3 - Peak Hours + Normal Supply:
- Time Multiplier: 1.5x (peak hours)
- Supply Multiplier: 1.0x (normal supply)
- Final Price: 100 × 1.5 × 1.0 = 150 STX/kWh
```

## Contract Architecture

### Data Structures

**Producer Management**
- `energy-producers`: Producer credentials, verification status, capacity
- `producer-earnings`: Sales statistics, earnings, active listings

**Energy Trading**
- `energy-listings`: Available energy with dynamic pricing
- `energy-transactions`: Completed purchases with price multipliers
- `user-energy-balance`: Consumer holdings and purchase history

**Smart Grid IoT**
- `iot-devices`: Device registry with verification status
- `energy-readings`: Raw sensor data (voltage, current, power factor)
- `device-readings-summary`: Aggregated device performance metrics

**Energy Storage**
- `storage-providers`: Battery capacity, stored energy, efficiency
- `storage-transactions`: Buy/sell operations with pricing data
- `storage-provider-earnings`: Profit analytics and ROI tracking

**Market Analytics**
- `market-metrics`: Real-time supply, demand, and pricing aggregates

## Security Features

### Input Validation
- Comprehensive parameter validation for all functions
- String length and format validation (1-100 characters)
- Numeric bounds checking (prevent overflow/underflow)
- Price validation (0 < price < 1,000,000)
- Energy amount limits (0 < amount < 1,000,000 kWh)

### Authorization Controls
- Producer ownership verification for listings
- Device ownership validation for IoT reporting
- Storage provider authorization for trading operations
- Admin-only functions for verification processes

### Safety Mechanisms
- Overflow protection in all calculations
- Price bounds to prevent market manipulation (0.5x - 3.0x)
- Cannot purchase own energy listings
- Active listing status validation
- Sufficient capacity checks for storage operations
- Energy availability verification before purchases

### Error Handling
21 distinct error codes for precise failure reporting:
- Authorization errors (owner-only, unauthorized, device-unauthorized)
- Validation errors (invalid amounts, prices, listings)
- State errors (not found, already exists, inactive)
- Business logic errors (insufficient energy/capacity, cannot buy own energy)

## Usage Examples

### Register and List Energy
```clarity
;; 1. Register as producer
(contract-call? .solarflow register-producer
  "SunPower Solutions"
  "California, USA"
  u50              ;; 50 kW capacity
  "NABCEP-2024"    ;; Certification
)
;; Returns: (ok u1) - producer-id

;; 2. Register IoT device
(contract-call? .solarflow register-iot-device
  u1               ;; producer-id
  "solar-inverter"
  "Primary Inverter"
  "SolarEdge"
  "SE10000H"
  "SN-123456789"
)
;; Returns: (ok u1) - device-id

;; 3. Report generation data
(contract-call? .solarflow report-energy-generation
  u1      ;; device-id
  u45     ;; 45 kWh generated
  u240    ;; 240V
  u187    ;; 187A current
  u950    ;; 0.95 power factor
  u35     ;; 35°C temperature
)

;; 4. Create listing
(contract-call? .solarflow create-energy-listing
  u1                        ;; producer-id
  u1000                     ;; 1000 kWh available
  u100                      ;; 100 STX/kWh base price
  u1440                     ;; Valid for ~10 days
  "SOLAR-CERT-2024-001"
)
;; Returns: (ok u1) - listing-id
```

### Purchase Energy as Consumer
```clarity
;; Check current dynamic price
(contract-call? .solarflow calculate-dynamic-price u100)
;; Returns: {price: u150, multiplier: u150, is-peak: true, supply-level: "normal"}

;; Purchase energy
(contract-call? .solarflow purchase-energy u1 u500)
;; Buys 500 kWh at current market price
;; Automatically calculates: price × amount + 2.5% platform fee
;; Returns: (ok u1) - transaction-id
```

### Energy Storage Operations
```clarity
;; 1. Register storage provider
(contract-call? .solarflow register-storage-provider
  "GridBattery Systems"
  "Texas, USA"
  u50000           ;; 50 MWh capacity
  "Lithium-Ion"
  u95              ;; 95% efficiency
)
;; Returns: (ok u1) - storage-provider-id

;; 2. Buy energy during off-peak (low prices)
(contract-call? .solarflow storage-buy-energy
  u1      ;; storage-provider-id
  u1      ;; listing-id
  u1000   ;; 1000 kWh to store
)

;; 3. Sell energy during peak hours (high prices)
(contract-call? .solarflow storage-sell-energy
  u1       ;; storage-provider-id
  u1000    ;; 1000 kWh to release
  u150     ;; 150 STX/kWh (profit from 100 STX buy price)
  u144     ;; Valid for ~1 day
)
```

### Analytics and Monitoring
```clarity
;; View market conditions
(contract-call? .solarflow get-market-metrics)
;; Returns: {total-supply-kwh, total-demand-24h, active-listings-count, average-price-per-kwh}

;; Check device performance
(contract-call? .solarflow get-device-summary u1)
;; Returns: {total-generation-kwh, average-daily-generation, total-readings, ...}

;; Monitor storage profitability
(contract-call? .solarflow get-storage-provider-earnings u1)
;; Returns: {net-profit, profit-margin, average-buy-price, average-sell-price, ...}
```

## Error Codes Reference

| Code | Constant | Description |
|------|----------|-------------|
| u100 | err-owner-only | Admin-only operation |
| u101 | err-not-found | Resource not found |
| u102 | err-invalid-producer | Invalid producer data |
| u103 | err-invalid-listing | Invalid listing parameters |
| u104 | err-already-exists | Resource already exists |
| u105 | err-insufficient-energy | Not enough energy available |
| u106 | err-unauthorized | Unauthorized operation |
| u107 | err-invalid-price | Invalid price value |
| u108 | err-invalid-amount | Invalid amount value |
| u109 | err-listing-inactive | Listing is not active |
| u110 | err-cannot-buy-own-energy | Self-purchase prohibited |
| u111 | err-invalid-data | Data validation failed |
| u112 | err-invalid-device | Invalid IoT device |
| u113 | err-device-not-verified | Device not verified |
| u114 | err-invalid-reading | Invalid sensor reading |
| u115 | err-device-unauthorized | Device operation unauthorized |
| u116 | err-invalid-pricing-config | Invalid pricing configuration |
| u117 | err-invalid-storage-provider | Invalid storage provider |
| u118 | err-insufficient-storage-capacity | Not enough storage capacity |
| u119 | err-storage-provider-inactive | Storage provider inactive |
| u120 | err-invalid-storage-operation | Invalid storage operation |
| u121 | err-insufficient-stored-energy | Not enough stored energy |

## Roadmap

### Completed ✅
- [x] Core energy trading marketplace
- [x] Dynamic pricing algorithm with peak/off-peak rates
- [x] Supply/demand-based price adjustments
- [x] IoT device integration for smart grid
- [x] Real-time energy generation monitoring
- [x] Energy storage marketplace
- [x] Storage provider profit optimization
- [x] Comprehensive security and validation
- [x] Carbon offset tracking

### Planned 🚀
- [ ] Multi-token payment support (STX, stablecoins)
- [ ] Predictive pricing using historical data
- [ ] Peer-to-peer energy contracts
- [ ] Grid balancing incentives
- [ ] Renewable energy certificate (REC) NFTs
- [ ] Weather-based price forecasting integration
- [ ] Mobile app for IoT device management
- [ ] Advanced analytics dashboard
- [ ] Community governance (DAO)
- [ ] Cross-chain energy trading

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for new functionality
4. Ensure all tests pass (`clarinet test`)
5. Commit changes (`git commit -m 'Add amazing feature'`)
6. Push to branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request
