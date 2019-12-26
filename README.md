Slothcoin aka SLOTH 2019
========================

- Provisional website built from the original (2014) layout with updated links to binaries, source, exchange and mining pool:
 
   http://slothcoin.brozkeff.net

- Original Website (now just link to Windows binary)

   http://www.slothcoin.org/
 
 - Since commit 96c01e6 this source is marked as v1.3.1 build4 - modified to new URL, graphics and seed urls. Binaries build currently just for Linux 64bit (Ubuntu 16.04), Windows version stays on the older build.

- Wallet
   [Windows Binary (older - v1.3.1 build3)](http://slothcoin.brozkeff.net/download/SlothCoin-Windows.zip)

   [Linux x64 Binaries (current - v1.3.1 build4)](https://github.com/brozkeff/Slothcoin/releases/download/v1.3.1-build4/slothcoin-v1.3.1-build4+ubuntu16.04-amd64.zip) in Releases

   For the older build 3, [Download this config file, PLEASE change rpcuser and rpcpassword.](http://slothcoin.brozkeff.net/download/Slothcoin.conf)
   
   Put them in the same dir (or in Windows, ~/AppData/Roaming/Slothcoin, in Linux ~/.Slothcoin and start using slothcoin-qt or just as a daemon on a linux server, slothcoind. If you run a Linux server with a public IP, please open the port 5107 and serve as a public node, as of October 2019 it is urgently needed since very few publicly accessible nodes exist. If you add "gen=1" to the config the client will also (inefficiently) CPU-mine, helping to confirm transactions. Since the difficulty is low compared to more popular coins you can easily solo-mine using CPU and feel the excitement Bitcoin miners had cca 2009-2010 :-)

- Buy or Sell Slothcoin

   [Unnamed Exchange](https://www.unnamed.exchange/CoinInfo?id=SLOTH)

- Market Data

   https://www.unnamed.exchange/CoinInfo?id=SLOTH

- Community Forum

   https://bitcointalk.org/index.php?topic=1168909.0

- Mining Pool

   https://pool.atomminer.com/


Technical Information version 1.3.1 build 3

+ SHA-3 keccak encryption algorithm
+ Difficulty retargeting using Kimoto Gravity Well
+ DIGI shield
+ Retargeting every block
+ 150 second blocktime
+ 120 block maturity times
+ 5 block transaction confirmation times

Total amount of coins: 92,233,720,368
Shortly after the year 2020 POW mining will stop.

Original Slothcoin Rewards up to block 299999

	     0 ..        4      5 *    50000000 =	   250.000.000
	     5 ..      100     96 *       10000	=	       960.000
	   101 ..    99999  99899 *      500000	=	49.949.500.000
	100000 ..   199999   100K *      250000 =	25.000.000.000
	200000 ..   299999   100K *      125000	=	12.500.000.000

Here rewards change. So it will stay within MAX_COIN(int64) limits.

        300000 ..   300099    100 *     1000000 =	   100.000.000
        300100 ..   300299    200 *      500000	=	   100.000.000
        300300 ..   300699    400 *      250000	=	   100.000.000
        300700 ..   301499    800 *      125000	=	   100.000.000
        301500 ..   303099   1600 *       62500	=	   100.000.000
        303100 ..   304099   1000 *       31250 =	    31.250.000
        304100 ..   304599    500 *       10000 =	     5.000.000
        304600 ..   304819    220 *        5000 =	     1.100.000

And for a few years to come

        304820 ..  1229584 924765 *        4321 =	 3.995.909.565

To round it off				++	=	92.233.719.565

       1229585 ..  1230386    802 *           1	=	           802

    <  1230387, Total 92233720367 * COIN	
					++	=	92.233.720.367

License

Slothcoin is released under the terms of the MIT license. See `COPYING` for more
information or see http://opensource.org/licenses/MIT.

Brozkeff's note 10/2019:
Provisional website at slothcoin.brozkeff.net provided as a temporary cure for the lack of the reasonably well informative official website. Contact me at (ian at brozkeff net) if you have any questions. I am not a professional developer of the Slothcoin client, I just run one of the few public nodes. 

Edit 12/2019: In December 2019 I tried to modify the source to enter new seed nodes and change the graphics and URL, and managed to compile working Linux binary (Ubuntu 16.04 64bit only). 
