# How to Test

```shell
yarn
yarn test
```

The test code was written in `/test/StakingToken.test.js`.

The test preface is as following:

- The test is performed in hardhat local network
- All accounts are from hardhat
- 1st account is an owner of this contract
- 2nd account is customer1
- 3rd account is customer2
- The name of token is "StakingToken"
- The symbol of token is "XYZ"
- Set a time period constant T as 5 seconds, to be used for reward calculation
- The initial supply of token is 10**18 * 1000

The contract dynamics is as following:

- The smart contract is deployed at t0
- The reward pool R is split into 3 subpools
1. R1 = 20% of R, available after 2T has passed since contract deployment
2. R2 = 30% of R, available after 3T has passed since contract deployment
3. R3 = 50% of R, available after 4T has passed since contract deployment
- Deposit period: During the first period of T time the users can deposit tokens. After T has passed, no more deposits are allowed.
- Lock period: From moment t0+T to t0+2T, users cannot withdraw their tokens (If the user tries to remove tokens before T time has elapsed since they have deposited, the transaction should fail).
- Withdraw periods: After T2 has passed since contract deployment, the users can withdraw their tokens. However, the longer they wait, the bigger the reward they get
1. If a user withdraws tokens during the period t0+2T to t0+3T, they collect a proportional amount of the reward pool R1, according to the ratio of the number of tokens they have staked compared to the total number of tokens staked on the contract (by all users).
2. If a user withdraws tokens during the period t0+3T to t0+4T, they collect a proportional amount of the remaining reward pool R1 and R2, according to the proportion of the number of tokens they have staked compared to the total number of tokens staked on the contract (by all users)
3. If the user withdraws tokens after 4T has passed since contract deployment, they can receive the full reward of R (R1+R2+R3) proportionally to their ratio of tokens in the total pool
4. If no user waits for the last period (for 4T to pass), the remaining tokens on the contract can be withdrawn by the bank (contract owner). In no other situation can the bank owner remove tokens from the contract.

The example is as following:

- User 1 stakes S1 = 1000 XYZ during deposit period
- User 2 stakes S2 = 4000 XYZ during deposit period
- Reward pool R = 1000 XYZ (R1 = 200XYZ, R2 = 300 XYZ, R3 = 500 XYZ)
- User 1 withdraws their tokens in period t0+2T to t0+3T
1. User 1 should receive their initial deposit of 1000 XYZ and
2. A reward of 40 XYZ, proportional to their amount of tokens in the pool
- User 2 is impatient and withdraws their tokens in period t0+3T to t0+4T
1. User 2 should receive their their initial deposit of 4000 XYZ and
2. A reward of 460 XYZ, which is 100% of the remaining R1 tokens, and 100% of the remaining R2 tokens (as user 2 tokens are 100% of the remaining staked tokens in the bank)
- After 4T has passed, the bank can withdraw the remaining reward (500XYZ) since no user has any more deposits to withdra

# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```
