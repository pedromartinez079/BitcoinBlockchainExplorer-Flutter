import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import 'package:bitcoin_blockchain_explorer/screens/settings.dart';
import 'package:bitcoin_blockchain_explorer/screens/search.dart';
import 'package:bitcoin_blockchain_explorer/screens/tx.dart';
import 'package:bitcoin_blockchain_explorer/widgets/card.dart';
import 'package:bitcoin_blockchain_explorer/services/blockchain.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({
    super.key,
    required this.address,
  });

  final String address;

  @override
  ConsumerState<WalletScreen> createState() {
    return _WalletScreenState();
  }
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  Map<dynamic, dynamic>? _walletInformation;
  bool _isWalletInformationFetched = false;
  Widget? _scaffoldBody;
  bool _showTxList = false;
  
  _getWalletInformation() async {
    // Get wallet information, Blockchain.info API
    try {
      final walletInformation = await fetchFromBlockchainInfo(
        'multiaddr?active=${widget.address}');
      
      setState(() {
        _walletInformation = jsonDecode(walletInformation['data']);
      });
      _isWalletInformationFetched = true;
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text('Blockchain.com API failed, ${e.toString()}'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // Show Tx list button method
  _onShowTxList() {
    setState(() {
      _showTxList = !_showTxList;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? walletInformation;
    String title = '';

    if (!_isWalletInformationFetched) {
      _getWalletInformation();
    }

    if (_walletInformation != null) {
      for (Map a in _walletInformation!['addresses']) {
        title = '$title ${a['address']}';
      }
      // Scaffold body if Wallet information exists
      walletInformation = Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Wallet information
            ExplorerElementCard(
              elements: CardElements(
                title: title,
                textLines: [
                  '',
                  'Balance(sats): ${_walletInformation!['wallet']['final_balance']}',
                  'Total received(sats): ${_walletInformation!['wallet']['total_received']}',
                  'Total sent(sats): ${_walletInformation!['wallet']['total_sent']}',
                ],
              ), 
              onTap: () {},
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // List of Txs button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _walletInformation!['txs'] != null ?
                      _onShowTxList : null,
                    icon: Icon(Icons.list),
                    label: Text('List of Txs'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            // Show tx list?
            if (_showTxList)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0), // Opcional: esquinas redondeadas
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _walletInformation!['txs'].length,
                  itemBuilder: (context, index) {
                    final tx = _walletInformation!['txs'][index];
                    return ListTile(
                      title: Text(tx['hash']),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => TxScreen(
                              txHash: tx['hash'],
                            ),
                          )
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      );
      setState(() {
        _scaffoldBody = walletInformation;
      });
    } else {
      // Scaffolf Body if Wallet information is not ready
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
        title: Text('Wallet'),
        actions: [
          // Update screen
          IconButton(
            onPressed: () {
              setState(() {
                _isWalletInformationFetched = false;
              });
            },
            icon: Icon(Icons.refresh),
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