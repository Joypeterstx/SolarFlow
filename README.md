# SolarFlow

A decentralized peer-to-peer marketplace for solar energy trading built on the Stacks blockchain.

## Overview

SolarFlow enables solar energy producers to sell excess energy directly to consumers without intermediaries. The platform provides transparent pricing, verifiable renewable energy certificates, and automatic carbon offset tracking.

## Features

- **Producer Registration**: Solar energy producers can register with capacity and certification details
- **Energy Listings**: Create time-limited energy sale listings with custom pricing
- **Direct Trading**: Consumers can purchase energy directly from producers
- **Carbon Tracking**: Automatic calculation of carbon offset benefits
- **Reputation System**: Track producer performance and buyer history
- **Platform Fees**: Transparent fee structure with configurable rates

## Smart Contract Functions

### Producer Management
- `register-producer`: Register as a solar energy producer
- `verify-producer`: Admin function to verify producer credentials
- `get-producer`: Retrieve producer information

### Energy Trading
- `create-energy-listing`: List energy for sale with expiry date
- `purchase-energy`: Buy energy from available listings
- `deactivate-listing`: Cancel active energy listings

### Data Access
- `get-listing`: View energy listing details
- `get-user-balance`: Check energy balance and purchase history
- `get-producer-earnings`: View producer sales statistics

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for testnet/mainnet deployment

### Installation
1. Clone the repository
2. Run `clarinet check` to verify contract syntax
3. Use `clarinet test` to run the test suite
4. Deploy with `clarinet deploy`

## Contract Architecture

The contract uses five main data structures:
- `energy-producers`: Store producer credentials and verification status
- `energy-listings`: Track available energy for sale
- `energy-transactions`: Record all completed purchases
- `user-energy-balance`: Track consumer energy holdings
- `producer-earnings`: Monitor producer sales performance

## Security Features

- Input validation for all parameters
- Authorization checks for producer-only functions
- Expiry date validation for listings
- Platform fee calculations with overflow protection
- Proper error handling throughout

## License

MIT License - see LICENSE file for details

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with detailed description

## Support

For questions or issues, please create an issue in the GitHub repository.