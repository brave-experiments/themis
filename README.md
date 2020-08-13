# THEMIS prototype

This repository contains the prototypes and measurements code for the client and 
smart contract to run THEMIS, a novel privacy-by-design ad platform that is
decentralized and requires zero trust from users.

This implementation is based on [THEMIS: Decentralized and Trustless Ad Platform
with Reporting Integrity](https://arxiv.org/abs/2007.05556), by the Brave
Research team.

### Contents:

- [THEMIS client implementation](./themis-client-rs): Implementation of the client-side
  logic which interacts with the sidechain. This folder also includes
benchmarks, tests and end-to-end examples of how the protocol works.

- [THEMIS policy smart contract](./themis-policy-contract): Implementation of
  the THEMIS policy smart contract, which calculates the user ad rewards based
on the user's encrypted input.

- [Payment measurements](./payment-measurements): Setup used to calculate
  scalability of confidential payments using AZTEC in the context of THEMIS.

--- 

*Abstract*: Online advertising fuels the (seemingly)free internet. However, although users
can access most websites free of charge, they need to pay a heavy cost on their
privacy and blindly trust third parties and intermediaries that absorb great
amounts of ad revenues and user data. This is one of the reasons users opt out
from advertising by resorting ad blockers that in turn cost publishers millions
of dollars in lost ad revenues. Existing privacy-preserving advertising
approaches(e.g., Adnostic, Privad, Brave Ads) from both industry and academia
cannot guarantee the integrity of the performance analytics they provide to
advertisers, while they also rely on centralized management that users have to
trust without being able to audit.In this paper, we propose THEMIS, a novel
privacy-by-design ad platform that is decentralized and requires zero trust from
users. THEMIS (i) provides auditability to all participants, (ii) rewards users
for viewing ads,and (iii) allows advertisers to verify the performance and
billing reports of their ad campaigns. To demonstrate the feasibility and
practicability of our approach,we implemented a prototype of THEMIS using a
combination of smart contracts and zero-knowledge schemes.Performance
evaluation results show that during ad reward payouts, THEMIS can support more
than 51M concurrent users on a single-sidechain setup or 153Musers on a
multi-sidechain setup, thus proving that THEMIS scales linearly.
