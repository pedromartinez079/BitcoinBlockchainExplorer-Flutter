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
    required this.updateWallets,
  });

  final String walletName;
  final List<String> addresses;
  final double btcPrice;
  final Function updateWallets;

  @override
  ConsumerState<WalletCard> createState() {
    return _WalletCardState();
  }
}

class _WalletCardState extends ConsumerState<WalletCard> {
  final _addressController = TextEditingController();
  List<dynamic> _addresses = [];
  bool _showAddresses = false;
  double _walletTotal = 0;

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
    final regex = RegExp(r'^[a-zA-Z0-9]$');
    if (address.isEmpty || address == '' || !regex.hasMatch(address[0])) {
      return;
    }

    ref.read(walletsProvider.notifier).addAddress(widget.walletName, address);

    setState(() {
      _addresses = ref.read(walletsProvider.notifier).getAddresses(widget.walletName);
      _showAddresses = _addresses.isNotEmpty;
    });

    _calculateWalletTotal();

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

  Future<void> _calculateWalletTotal() async {
    double total = 0;
    for (String address in _addresses) {
      final values = await _getAddressValues(address);
      total += values['dollarValue'];
    }
    setState(() {
      _walletTotal = total;
    });
  }

  _deleteWallet() {
    ref.read(walletsProvider.notifier).deleteWallet(widget.walletName);

    widget.updateWallets();

    List wList = ref.read(walletsProvider.notifier).getWallets();
    storeWallets(wList);
  }

  @override
  void initState() {
    super.initState();
    _addresses = ref.read(walletsProvider.notifier).getAddresses(widget.walletName);
    if (_addresses.isNotEmpty) {
      _showAddresses = true;
      _calculateWalletTotal();
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final subtitleStyle = Theme.of(context).textTheme.titleSmall;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onVerticalDragEnd: (i) {_deleteWallet();},
          child: Text('Wallet ${widget.walletName} | USD ${_walletTotal.toStringAsFixed(2)}', style: titleStyle)
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
              deleteAddress() {
                ref.read(walletsProvider.notifier).deleteAddress(widget.walletName, a);

                setState(() {
                  _addresses = ref.read(walletsProvider.notifier).getAddresses(widget.walletName);
                  _showAddresses = _addresses.isNotEmpty;
                });

                _calculateWalletTotal();

                List wList = ref.read(walletsProvider.notifier).getWallets();
                storeWallets(wList);                
              }
              return FutureBuilder(
                future: _getAddressValues(a),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator()
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var values = snapshot.data;
                    double btcValue = values?['btcValue'];
                    double dollarValue = values?['dollarValue'];                 
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: GestureDetector(
                        onTap: showAddress,
                        onVerticalDragEnd: (i) {deleteAddress();},
                        child: Column(
                          children: [
                            Row(
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
                            const SizedBox(height:5),
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