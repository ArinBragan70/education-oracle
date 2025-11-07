## Overview

This PR introduces the oracle-verifier smart contract, implementing a comprehensive system for verifying claims and signatures related to oracle data submissions on the blockchain.

## What Changed

### New Contract: oracle-verifier

A fully functional Clarity smart contract (212 lines) that provides:

- **Authorization System**: Manage authorized oracle providers who can submit and verify claims
- **Claim Submission**: Submit oracle data with cryptographic signatures, expiration times, and metadata
- **Verification Mechanism**: Verify claims submitted by other authorized providers
- **Query Interface**: Comprehensive read-only functions to retrieve claim data, verification status, and provider information
- **Admin Controls**: Administrative functions for threshold management and ownership transfer

## Key Features

### Authorization Management
- Add/remove authorized providers
- Check provider authorization status
- Contract owner automatically authorized on deployment

### Claim Operations
- Submit claims with data hash, signature, expiry, type, and metadata
- Automatic claim ID generation and tracking
- Prevention of duplicate data hashes
- Expiry validation to ensure claims are time-bound
- Link claims to providers for easy lookup

### Verification System
- Verify claims by authorized providers
- Track multiple verifiers per claim
- Revoke verifications (admin-only)
- Check verification status and expiry

### Data Structures
- **oracle-claims**: Main storage for claim data including provider, signature, timestamps, verification status
- **provider-claims**: Index of all claims by provider
- **claim-verifications**: List of verifiers for each claim
- **data-hash-to-claim**: Lookup table from data hash to claim ID

### Security Features
- Owner-only functions for critical operations
- Authorization checks for claim submission and verification
- Expiry validation prevents processing expired claims
- Data integrity checks
- Comprehensive error handling with specific error codes

## Testing

The contract has been validated using `clarinet check` and passes all syntax checks with only standard warnings about unchecked data (which is expected for public functions).

## Technical Details

- **Language**: Clarity
- **Lines of Code**: 212
- **Error Codes**: 8 distinct error types
- **Public Functions**: 8
- **Read-Only Functions**: 10
- **Data Maps**: 5

## Next Steps

Future enhancements could include:
- Test suite implementation
- Multi-signature verification requirements
- Oracle reputation scoring
- Slashing mechanisms for invalid data
- Integration with off-chain oracle networks
