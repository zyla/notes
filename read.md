## [ff](https://github.com/ff-notes/ff) distributed note taker

- TIL:
  [Test.QuickCheck.conjoin](https://hackage.haskell.org/package/QuickCheck-2.11.3/docs/Test-QuickCheck.html#v:conjoin)
  - Take the conjunction of several properties.

- [Hmmm](https://github.com/ff-notes/ff/blob/d4866f041b94857640f0b0d433c3cc2a6d248592/test/Main.hs#L243).
  It seems that the format it uses for RGA strings uses `'\0'` as a some sort of
  special case. Need to read more about RGA to find out what that is.

- Note text is edited in a normal editor (unlike Kleppman's collaborative
  editor), and [later a computed diff is applied to the RGA](https://github.com/cblp/crdt/blob/9d4d9978ad874c3a5c7626021b10268c04354efd/crdt/lib/CRDT/Cv/RGA.hs#L79)
