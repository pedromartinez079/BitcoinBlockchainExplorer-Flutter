import 'dart:convert';
import 'package:bitcoin_blockchain_explorer/services/blockchain.dart';
import 'package:bitcoin_blockchain_explorer/widgets/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitcoin_blockchain_explorer/providers/wallets_provider.dart';


class AddressTrackerScreen extends ConsumerStatefulWidget {
  const AddressTrackerScreen({super.key,});

  @override
  ConsumerState<AddressTrackerScreen> createState() {
    return _AddressTrackerScreenState();
  }
}

class _AddressTrackerScreenState extends ConsumerState<AddressTrackerScreen> {
  final _walletController = TextEditingController();
  double _btcPrice = 0;
  bool isBtcPriceFetched = false;
  List<dynamic> _wallets = [];
  bool _showWallets = false;

  _addWallet() {
    final name = _walletController.text;
    final regex = RegExp(r'^[a-zA-Z0-9]$');
    if (name.isEmpty || name == '' || !regex.hasMatch(name[0])) {
      return;
    }
    ref.read(walletsProvider.notifier).addWallet(Wallet(name: name, addresses:[]));
    setState(() {
      _wallets = ref.read(walletsProvider.notifier).getWallets();
      _showWallets = _wallets.isNotEmpty;
    });
  }

  _updateWallets() {
    setState(() {
      _wallets = ref.read(walletsProvider.notifier).getWallets();
      _showWallets = _wallets.isNotEmpty;
    });
  }

  _getbtcPrice() async {
    try {
      final fetchedInformation = await fetchFromBlockchainInfo('ticker');
      final fetchedPrices = jsonDecode(fetchedInformation['data']);
      final usd = fetchedPrices['USD']['last'];
      setState(() {
        _btcPrice = usd;
      });
    } catch(e) {
      _btcPrice = 0;
    }
    setState(() {
      isBtcPriceFetched = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _wallets = ref.read(walletsProvider.notifier).getWallets();
    if (_wallets.isNotEmpty) {
      _showWallets = true;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    if (!isBtcPriceFetched) {
      _getbtcPrice();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Address Tracker'),
        actions: [
          // Update screen
          IconButton(
            onPressed: _updateWallets,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bitcoin USD ${_btcPrice.toStringAsFixed(2)}',
                  style: titleStyle,
                ),
                const SizedBox(height:20),
                Text(                  
                  '+ -> add wallet, add address\n'
                  'Vertical drag -> delete address, delete wallet',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height:10),
                // Add Wallet 
                TextField(
                  controller: _walletController,
                  obscureText: false,
                  decoration: InputDecoration(
                    labelText: 'Wallet name',
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.add,
                      ),
                      onPressed: _addWallet,
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height:15),
                if (_showWallets)
                  Column(
                    children: _wallets.map((w) => WalletCard(
                      walletName: w.name,
                      addresses: w.addresses,
                      btcPrice: _btcPrice,
                      updateWallets: _updateWallets,
                    ),).toList(),
                  ),
                  
              ],
            ),
          ),
        ),
      ),
    );
  }
}