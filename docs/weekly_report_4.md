## Weekly Report, week 4

### What have I done this week?

I first started with implementing feedback from previous round, I converted the huffman coding from a JSON format to a binary format. I added metric to see how it compresses and noticed that there must be a bug somewhere but didn't have time to fix it.
Then I started looking into how to implement LZ77 encoding. I added a dirty implementation and kept improving it. I added a simple disk format to test if both the decoding and encoding steps work as expected. I did some minor clean up to the utils.

### How The Project Has Progressed

I have two algoriths implemented but serious flaws remain. LZ77 lacks proper disk format and Huffman coding needs optimizations.

### What I Learned This Week / Today

The basics how LZ77 works.

### What Was Unclear Or Difficult?

Still a bit lost on how to write this data to the disk in an optimized format

### What Will I Do Next?

Add the missing tests that I didn't have time to implement this week as I just run the functions against real data. Add proper disk format to LZ77 and fix huffman coding. Tidy up everything.

### LLM usage

## Hour keeping

| Day   | Time Spent (hours) | Description |                                                                                                                                                                                                                 |
| ----- | ------------------ | ----------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 7.4.  | 1                  |             | Clean up the previous weeks solution                                                                                                                                                                            |
| 13.4. | 6                  |             | Added a binary output for the huffman coding, added some metric about the encoded data. Started looking how to implement the LZ77 algorithm. Add very early and flawed implementation for the LZ77 disk format. |
| Total | 7                  |             |
