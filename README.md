# SolarFlow - Dynamic Pricing Edition

A decentralized peer-to-peer marketplace for solar energy trading built on the Stacks blockchain with intelligent dynamic pricing algorithms.

## Overview

SolarFlow enables solar energy producers to sell excess energy directly to consumers without intermediaries. The platform features real-time dynamic pricing based on supply/demand conditions and time-of-day patterns, providing transparent pricing, verifiable renewable energy certificates, and automatic carbon offset tracking.

## New Features - Dynamic Pricing Algorithm

### 🚀 Smart Pricing Engine
- **Time-Based Pricing**: Automatic price adjustments during peak hours (8 AM - 10 PM)
- **Supply-Demand Balancing**: Real-time price modifications based on market availability
- **Peak Hour Multipliers**: Higher prices during high-demand periods
- **Market Efficiency**: Automatic price discovery for optimal energy trading

### 📊 Pricing Mechanics
- **Peak Hours**: 1.5x multiplier during high-demand periods
- **Low Supply**: 2.0x multiplier when energy supply is scarce (<1,000 kWh)
- **High Supply**: 0.8x multiplier when energy is abundant (>10,000 kWh)
- **Price Bounds**: Intelligent limits (0.5x - 3.0x) prevent extreme pricing

### ⚡ Real-Time Updates
- Dynamic price calculation for each transaction
- Market metrics tracking and updating
- Automatic listing price refresh
- Historical price multiplier tracking

## Core Features

- **Producer Registration**: Solar energy producers can register with capacity and certification details
- **Dynamic Energy Listings**: Create listings with base prices that adjust automatically
- **Smart Grid Integration**: IoT device connectivity for real-time energy monitoring
- **Intelligent Trading**: Purchase energy at market-optimized prices
- **Carbon Tracking**: Automatic calculation of carbon offset benefits
- **Reputation System**: Track producer performance and buyer history
- **Transparent Fees**: Configurable platform fee structure (default 2.5%)

## Smart Contract Functions

### Producer Management
- `register-producer`: Register as a solar energy producer
- `verify-producer`: Admin function to verify producer credentials
- `get-producer`: Retrieve producer information

### Dynamic Energy Trading
- `create-energy-listing`: List energy with base price for dynamic adjustment
- `update-listing-price`: Refresh listing price based on current market conditions
- `purchase-energy`: Buy energy at current dynamic market price
- `deactivate-listing`: Cancel active energy listings

### IoT Smart Grid Integration
- `register-iot-device`: Connect IoT devices to producers
- `verify-iot-device`: Admin verification of IoT devices
- `report-energy-generation`: Record real-time energy generation data
- `report-energy-consumption`: Track energy consumption metrics

### Dynamic Pricing System
- `calculate-dynamic-price`: Get current market-adjusted price
- `get-pricing-config`: View current pricing parameters
- `update-pricing-config`: Admin function to adjust pricing algorithms
- `is-peak-hours`: Check if current time is peak demand period
- `get-supply-demand-multiplier`: View current supply/demand multiplier

### Data Access & Analytics
- `get-listing`: View energy listing details with current pricing
- `get-user-balance`: Check energy balance and purchase history
- `get-producer-earnings`: View producer sales statistics
- `get-market-metrics`: Access real-time market data
- `get-device-summary`: IoT device performance analytics

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for testnet/mainnet deployment

### Installation
1. Clone the repository
2. Run `clarinet check` to verify contract syntax
3. Use `clarinet test` to run the test suite
4. Deploy with `clarinet deploy`

## Dynamic Pricing Configuration

### Default Settings
- **Peak Hours**: 8 AM - 10 PM daily
- **Peak Multiplier**: 1.5x base price
- **Low Supply Threshold**: 1,000 kWh
- **High Supply Threshold**: 10,000 kWh
- **Low Supply Multiplier**: 2.0x base price
- **High Supply Multiplier**: 0.8x base price

### Pricing Examples
```
Base Price: 100 STX/kWh

During Peak Hours + Low Supply:
Current Price = 100 × 1.5 × 2.0 = 300 STX/kWh

During Off-Peak + High Supply:
Current Price = 100 × 1.0 × 0.8 = 80 STX/kWh
```

## Contract Architecture

The contract uses enhanced data structures:
- `energy-producers`: Store producer credentials and verification status
- `energy-listings`: Track available energy with dynamic pricing
- `energy-transactions`: Record all completed purchases with price multipliers
- `user-energy-balance`: Track consumer energy holdings
- `producer-earnings`: Monitor producer sales performance
- `market-metrics`: Real-time supply/demand analytics
- `iot-devices`: Smart grid device registry
- `energy-readings`: IoT device data collection
- `device-readings-summary`: Aggregated device performance

## Security Features

- Comprehensive input validation for all parameters
- Authorization checks for producer and device operations
- Overflow protection in all calculations
- Price bounds to prevent market manipulation
- Proper error handling throughout all functions
- IoT device verification and authorization
- Market metrics validation and integrity checks

## API Usage Examples

### Create Dynamic Listing
```clarity
(create-energy-listing 
  u1                     ;; producer-id
  u1000                  ;; energy-amount-kwh
  u100                   ;; base-price-per-kwh
  u1440                  ;; expiry-blocks (10 days)
  "SOLAR-CERT-2024-001"  ;; renewable-certificate
)
```

### Purchase Energy at Market Price
```clarity
(purchase-energy u1 u500) ;; listing-id, energy-amount-kwh
;; Price calculated automatically based on current market conditions
```

### Check Current Pricing
```clarity
(calculate-dynamic-price u100) ;; Returns current market price for 100 STX base
;; Returns: {price: u150, multiplier: u150, is-peak: true, supply-level: "normal"}
```

---

**Latest Update**: Dynamic Pricing Algorithm v1.0 - Real-time market-based pricing with supply/demand optimization