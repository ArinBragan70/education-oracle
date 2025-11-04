## Overview

This PR introduces the oracle-verifier smart contract to the Education Oracle platform, establishing a robust system for verifying claims and signatures related to oracle data submissions.

## Changes

### Smart Contract Implementation

**oracle-verifier.clar** (212 lines)
- Comprehensive claim submission and verification system
- Authorization management for data providers
- Claim lifecycle tracking with expiry validation
- Signature verification capabilities
- Admin controls for threshold management

### Key Features

1. **Authorization System**
   - Provider authorization management
   - Role-based access control
   - Admin-only privileged operations

2. **Claim Management**
   - Submit oracle claims with metadata
   - Track claim status and verification
   - Hash-based claim lookup
   - Provider claim history

3. **Verification Logic**
   - Multi-verifier support
   - Expiry-based validation
   - Revocation capabilities
   - Verification threshold configuration

4. **Data Structures**
   - Efficient mapping for claims and providers
   - Support for claim metadata and types
   - Cryptographic signature storage

### Contract Functions

**Public Functions:**
- `add-authorized-provider` - Authorize new data providers
- `remove-authorized-provider` - Revoke provider authorization
- `submit-claim` - Submit oracle data claims
- `verify-claim` - Verify submitted claims
- `revoke-verification` - Admin revocation of verification
- `set-verification-threshold` - Configure verification requirements
- `transfer-admin` - Transfer administrative control

**Read-Only Functions:**
- `is-authorized-provider` - Check provider authorization
- `get-claim` - Retrieve claim by ID
- `get-claim-by-hash` - Lookup claim by data hash
- `get-provider-claims` - Get all claims by provider
- `get-claim-verifications` - Get verifiers for a claim
- `is-claim-verified` - Check verification status
- `is-claim-expired` - Check expiry status
- `get-claim-count` - Total claims submitted
- `get-admin` - Current admin principal
- `get-verification-threshold` - Current threshold

## Technical Details

- **Language:** Clarity
- **Contract Size:** 212 lines
- **Error Codes:** 8 distinct error types
- **Data Maps:** 5 core data structures
- **Security:** Access control on all state-modifying operations

## Testing

Contract passes `clarinet check` with warnings addressed for production readiness.

## Configuration

Updated `Clarinet.toml` with oracle-verifier contract configuration.
