import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:bitcoin_blockchain_explorer/services/getblock.dart';
import 'package:bitcoin_blockchain_explorer/services/blockchain.dart';
import 'package:bitcoin_blockchain_explorer/providers/settings_provider.dart';

import 'package:bitcoin_blockchain_explorer/screens/settings.dart';
import 'package:bitcoin_blockchain_explorer/screens/search.dart';
import 'package:bitcoin_blockchain_explorer/screens/block.dart';
import 'package:bitcoin_blockchain_explorer/widgets/card.dart';

class NetworkStatusScreen extends ConsumerStatefulWidget {
  const NetworkStatusScreen({super.key,});

  @override
  ConsumerState<NetworkStatusScreen> createState() {
    return _NetworkStatusScreenState();
  }
}

class _NetworkStatusScreenState extends ConsumerState<NetworkStatusScreen> {
  Map<String, dynamic>? _networkStatus;
  bool _isNetworkStatusFetched = false;
  Widget? _scaffoldBody;

  _getNetworkStatus() async {
    // Estimate next halving, uses last block height and actual reward
    estimateNextHalving(blocks, blockreward) {
      final int height = blocks;
      const int blocksInterval = 210000;
      final int nextHalvingBlock = ((height + blocksInterval - 1) ~/ blocksInterval) * blocksInterval;
      final int blocksLeft = nextHalvingBlock - height;
      final int avgBlockTimeSec = 600; // 10 minutes
      final int secondsLeft = blocksLeft * avgBlockTimeSec;
      final Duration duration = Duration(seconds: secondsLeft);
      final DateTime estimatedDate = DateTime.now().add(duration);
      final double nextHalvingSubsidy = double.parse(blockreward) / 2;      
      return { 
        "nextHalvingBlock": nextHalvingBlock, 
        "blocksLeft": blocksLeft,
        "nextHalvingEstimatedDate": DateFormat.yMMMMd().add_jm().format(estimatedDate), 
        "nextHalvingSubsidy": nextHalvingSubsidy };
    }

    // Format for big numbers
    String formatCompact(double value, {int decimals = 2}) {
      if (!value.isFinite) return value.toString();

      final sign = value < 0 ? '-' : '';
      double absValue = value.abs();

      const List<String> suffixes = ['', 'K', 'M', 'B', 'T', 'P', 'E'];
      int idx = 0;

      while (absValue >= 1000 && idx < suffixes.length - 1) {
        absValue /= 1000;
        idx++;
      }

      String base = absValue.toStringAsFixed(decimals);

      if (base.contains('.')) {
        base = base.replaceAll(RegExp(r'0+$'), '');
        base = base.replaceAll(RegExp(r'\.$'), '');
      }

      return '$sign$base${suffixes[idx]}';
    }

    // Get NetworkStatus information
    try {
      final getblockToken = ref.watch(settingsProvider).token;
      final blocks = await fetchFromGetBlock(getblockToken, 'getblockcount', []);
      final hashrate = await fetchFromGetBlock(getblockToken, 'getnetworkhashps', []);
      final difficulty = await fetchFromGetBlock(getblockToken, 'getdifficulty', []);
      final rewardperblock = await fetchFromBlockchainInfo('q/bcperblock');
      final mempool = await fetchFromGetBlock(getblockToken, 'getmempoolinfo', []);
      final estimatedfees = await fetchFromURL('https://mempool.space/api/v1/fees/recommended');
      final nexthalving = estimateNextHalving(blocks['result'], rewardperblock['data']);
      final totalcoins = await fetchFromBlockchainInfo('q/totalbc');
      final lastBlockHash = await fetchFromGetBlock(getblockToken, 'getbestblockhash', []);
      

      final networkStatus = {
        "blocks": blocks['result'],
        "hashrate": formatCompact(hashrate['result']),
        "difficulty": formatCompact(difficulty['result']),
        "rewardperblock": rewardperblock['data'],
        "mempool": mempool['result'],
        "estimatedfees": jsonDecode(estimatedfees['data']),
        "nexthalving": nexthalving,
        "totalcoins": formatCompact(double.parse(totalcoins['data'])/100000000, decimals: 6),
        "lastblockhash": lastBlockHash['result'],
      };
      
      setState(() {
        _networkStatus = networkStatus;
      });
      _isNetworkStatusFetched = true;
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.cyanAccent,
          content: Text('${e.toString()}\nCheck GetBlock token!'),
          duration: Duration(seconds: 5),
        ),        
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? networkStatus;
    List<String>? mempoolTextList;
    List<String>? estimatedFeesTextList;
    List<String>? nextHalvingTextList;

    if (!_isNetworkStatusFetched) { 
      _getNetworkStatus();
    }    

    if (_networkStatus != null) {
      mempoolTextList = [
        'Total Txs: ${_networkStatus!['mempool']['size']}',
        'Memory: ${_networkStatus!['mempool']['usage']}',
        'Total fee: ${_networkStatus!['mempool']['total_fee']}',
        'Minimum fee: ${_networkStatus!['mempool']['mempoolminfee']}',
      ];
      estimatedFeesTextList = [
        'Fastest: ${_networkStatus!['estimatedfees']['fastestFee']} sat/vB',
        'Half Hour: ${_networkStatus!['estimatedfees']['halfHourFee']} sat/vB',
        'Hour: ${_networkStatus!['estimatedfees']['hourFee']} sat/vB',
        'Economy: ${_networkStatus!['estimatedfees']['economyFee']} sat/vB',
        'Minimum: ${_networkStatus!['estimatedfees']['minimumFee']} sat/vB',
      ];
      nextHalvingTextList = [
        'Block Height: ${_networkStatus!['nexthalving']['nextHalvingBlock']}',
        'Blocks left: ${_networkStatus!['nexthalving']['blocksLeft']}',
        'ETA: ${_networkStatus!['nexthalving']['nextHalvingEstimatedDate']}',
        'Reward/block: ${_networkStatus!['nexthalving']['nextHalvingSubsidy']}',
      ];
      // Scaffold Body if NetworkStatus information exists
      networkStatus = Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Block height
            ExplorerElementCard(
              onTap: () {},
              elements: CardElements(
                title: 'Blocks',
                text: _networkStatus!['blocks'].toString(),
              )
            ),
            // Hashrate
            ExplorerElementCard(
              onTap: () {},
              elements: CardElements(
                title: 'Global Hashrate',
                subtitle: 'H/s (Last 24h)',
                text: _networkStatus!['hashrate'].toString(),
              )
            ),
            // Difficulty
            ExplorerElementCard(
              onTap: () {},
              elements: CardElements(
                title: 'Difficulty',
                text: _networkStatus!['difficulty'].toString(),
              )
            ),
            // Reward per block
            ExplorerElementCard(
              onTap: () {},
              elements: CardElements(
                title: 'Reward/block',
                subtitle: 'Bitcoin units',
                text: _networkStatus!['rewardperblock'].toString(),
              )
            ),
            // Mempool
            ExplorerElementCard(
              onTap: () {},
              elements: CardElements(
                tip: 'Fee: Bitcoin units',
                title: 'Mempool',
                subtitle: 'Transactions (Txs) waiting for confirmation...',
                textLines: mempoolTextList,
              )
            ),
            // Estimated fees
            ExplorerElementCard(
              onTap: () {},
              elements: CardElements(
                tip: 'sat/vB (satoshi/virtual Byte)',
                title: 'Estimated Fees',
                subtitle: 'Tx fee to get a confirmation within...',
                textLines: estimatedFeesTextList,
              )
            ),
            // Next halving information
            ExplorerElementCard(
              onTap: () {},
              elements: CardElements(
                title: 'Next Halving',
                textLines: nextHalvingTextList,
              )
            ),
            // Bitcoin supply
            ExplorerElementCard(
              onTap: () {},
              elements: CardElements(
                title: 'Bitcoin Supply',
                subtitle: 'Bitcoin units (Max. 21M)',
                text: _networkStatus!['totalcoins'].toString(),
              )
            ),
          ],
        ),
      );
      setState(() {
        _scaffoldBody = networkStatus;
      });
    } else {
      // Scaffolf Body if NetworkStatus information is not ready
      setState(() {
        _scaffoldBody = ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      });
    }    

    return Scaffold(
      appBar: AppBar(
        title: Text('Mainnet Network Status'),
        actions: [
          // Update screen
          IconButton(
            onPressed: () {
              setState(() {
                _isNetworkStatusFetched = false;
              });
            },
            icon: Icon(Icons.refresh),
          ),
          // Last Block screen
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => BlockScreen(
                    blockHash: _networkStatus!['lastblockhash'],
                  ),
                )
              );
            },
            icon: Icon(Icons.currency_bitcoin),
          ),
          // Search screen
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SearchScreen(),
                )
              );
            },
            icon: Icon(Icons.search),
          ),
          // Settings screen
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SettingsScreen(),
                )
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(child: _scaffoldBody),
    );
  }
}