
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bitcoin_blockchain_explorer/screens/address.dart';
import 'package:bitcoin_blockchain_explorer/services/blockchain.dart';
import 'package:bitcoin_blockchain_explorer/providers/wallets_provider.dart';

class WalletCard extends ConsumerStatefulWidget {
  const WalletCard({
    super.key,
    required this.walletName,
    required this.addresses,
    required this.btcPrice,
  });

  final String walletName;
  final List<String> addresses;
  final double btcPrice;

  @override
  ConsumerState<WalletCard> createState() {
    return _WalletCardState();
  }
}

class _WalletCardState extends ConsumerState<WalletCard> {
  final _addressController = TextEditingController();
  List<dynamic> _addresses = [];
  bool _showAddresses = false;

  Future<void> storeWallets(List wallets) async {
    final prefs = await SharedPreferences.getInstance();
    
    try {
      String wListString = jsonEncode(wallets.map((w) => w.toJson()).toList());
      await prefs.setString('wallets', wListString);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.cyanAccent,
          content: Text('Information saved.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.cyanAccent,
          content: Text(e.toString()),
        ),
      );
    }
  }

  _addAddress() {
    final address = _addressController.text;
    if (address.isEmpty || address == '') {
      return;
    }

    ref.read(walletsProvider.notifier).addAddress(widget.walletName, address);

    setState(() {
      _addresses = ref.read(walletsProvider.notifier).getAddresses(widget.walletName);
    });

    List wList = ref.read(walletsProvider.notifier).getWallets();
    storeWallets(wList);
  }

  Future<Map> _getAddressValues(String address) async {
    double btcValue = 0;
    double dollarValue = 0;
    try {
      final fetchedInformation = await fetchFromBlockchainInfo('balance?active=$address');
      final addressInformation = jsonDecode(fetchedInformation['data']);
      btcValue = addressInformation[address]['final_balance'] / 100000000;
      dollarValue = btcValue * widget.btcPrice;
    } catch(e) {
      btcValue = 0;
      dollarValue = 0;
    }
    return {'btcValue': btcValue, 'dollarValue': dollarValue};
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final subtitleStyle = Theme.of(context).textTheme.titleSmall;

    setState(() {
      _addresses = ref.read(walletsProvider.notifier).getAddresses(widget.walletName);
    });    

    if (_addresses.isNotEmpty) {
      setState(() {
        _showAddresses = true;
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onLongPressUp: () {print('delete wallet');}, // delete wallet > AddressTrackerScreen function
          child: Text('Wallet ${widget.walletName}', style: titleStyle)
        ),
        TextField(
          controller: _addressController,
          obscureText: false,
          decoration: InputDecoration(
            labelText: 'Address',
            suffixIcon: IconButton(
                  icon: Icon(
                    Icons.add,
                  ),
                  onPressed: _addAddress,
                ),              
            ),          
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height:15),
        if (_showAddresses)
          Column(
            children: _addresses.map((a) {
              showAddress() {
                if (a != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => AddressScreen(address: a),                
                    )
                  );
                }
              }
              deleteAddress() {}
              return FutureBuilder(
                future: _getAddressValues(a),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var values = snapshot.data;
                    double btcValue = values?['btcValue'];
                    double dollarValue = values?['dollarValue'];
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: InkWell(
                        onTap: showAddress,
                        onLongPressUp: deleteAddress,
                        child: Row(
                          children: [
                            Text(
                              a,
                              style: subtitleStyle,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              '$btcValue btc',
                              style: subtitleStyle,
                            ),
                            const SizedBox(width: 15),
                            Text(
                              '\$ ${dollarValue.toStringAsFixed(2)}',
                              style: subtitleStyle,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              );
            }).toList(),                    
          ),
        const SizedBox(height:25),
      ],
    );
  }
}