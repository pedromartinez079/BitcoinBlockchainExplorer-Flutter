import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import 'package:bitcoin_blockchain_explorer/screens/settings.dart';
import 'package:bitcoin_blockchain_explorer/screens/search.dart';
import 'package:bitcoin_blockchain_explorer/screens/tx.dart';
import 'package:bitcoin_blockchain_explorer/widgets/card.dart';
import 'package:bitcoin_blockchain_explorer/services/blockchain.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({
    super.key,
    required this.address,
  });

  final String address;

  @override
  ConsumerState<AddressScreen> createState() {
    return _AddressScreenState();
  }
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  Map<dynamic, dynamic>? _addressInformation;
  bool _isAddressInformationFetched = false;
  Widget? _scaffoldBody;
  bool _showTxList = false;
  
  _getWalletInformation() async {
    // Get wallet information, Blockchain.info API
    try {
      final addressInformation = await fetchFromBlockchainInfo(
        'multiaddr?active=${widget.address}');
      
      setState(() {
        _addressInformation = jsonDecode(addressInformation['data']);
      });
      _isAddressInformationFetched = true;
    } catch(e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.cyanAccent,
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
    Widget? addressInformation;
    String title = '';

    if (!_isAddressInformationFetched) {
      _getWalletInformation();
    }

    if (_addressInformation != null) {
      for (Map a in _addressInformation!['addresses']) {
        title = '$title ${a['address']}';
      }
      // Scaffold body if Wallet information exists
      addressInformation = Padding(
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
                  'Balance(sats): ${_addressInformation!['wallet']['final_balance']}',
                  'Total received(sats): ${_addressInformation!['wallet']['total_received']}',
                  'Total sent(sats): ${_addressInformation!['wallet']['total_sent']}',
                ],
              ), 
              onTap: null,
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // List of Txs button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addressInformation!['txs'] != null ?
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
                  itemCount: _addressInformation!['txs'].length,
                  itemBuilder: (context, index) {
                    final tx = _addressInformation!['txs'][index];
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
        _scaffoldBody = addressInformation;
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
        title: Text('Address'),
        actions: [
          // Update screen
          IconButton(
            onPressed: () {
              setState(() {
                _isAddressInformationFetched = false;
                _addressInformation = null;
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
      body: SafeArea(child: SingleChildScrollView(child: _scaffoldBody)),
    );
  }
}