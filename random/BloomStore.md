# BloomStore

Shitty probabilistic key-value store for fixed size values. Constant space,
constant time operations (With respect to the number of keys. Linear in value
size, obviously.).

Can return wrong results (flipped bits in the value), with some probability.

First, let's make up some primitives.

## BloomBit

A data structure that "stores" one bit per key. Has a nonzero bit flip rate,
which I'm too lazy to calculate now.

Is a bit vector.

Like in Bloom filter, hash the key with N hash functions. So each key maps to a
set of bit indexes in the bitvector.

### Operation: set to 1

Set bit under each index to 1.

### Operation: set to 0

Set bit under each index to 0.

### Operation: read

Read bits from each index. Let `popcnt` be the number of `1`s. If `popcnt > N /
2`, then return `1`. Else return `0`.

## More bits

So we have an unreliable way to store a bit per key. We can store M-bit values
using M `BloomBit` instances.

Alternative: use `(key, bit index)` as the key in one big `BloomBit`.

## Reliability

So we have a way to store some bits by key, but the bits may flip.

In IT, the solution to crappy foundations is always adding more layers.

So the solution is obvious: Use ECC.

## Some observations

- Writes (even to different keys) do not commute, unlike in Bloom filters.

- After a write values are "fresh" (no errors). Then they "wear" over time as
  unrelated writes flip their bits.
