import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitcoin_blockchain_explorer/screens/settings.dart';
import 'package:bitcoin_blockchain_explorer/screens/block.dart';
import 'package:bitcoin_blockchain_explorer/screens/tx.dart';
import 'package:bitcoin_blockchain_explorer/screens/wallet.dart';
import 'package:bitcoin_blockchain_explorer/widgets/card.dart';
import 'package:bitcoin_blockchain_explorer/services/getblock.dart';
import 'package:bitcoin_blockchain_explorer/services/blockchain.dart';
import 'package:bitcoin_blockchain_explorer/providers/settings_provider.dart';

class SearchScreen extends ConsumerStatefulWidget{
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() {
    return _SearchScreenState();
  }
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  bool _showBlockResults = false;
  bool _showTxResults = false;
  bool _showWalletResults = false;
  bool _nothing = true;
  bool _firstSearch = false;

  // Search button method
  _onSearch() async {
    final getblockToken = ref.watch(settingsProvider).token;
    final searchString = _searchController.text;
    final regex = RegExp(r'^[a-zA-Z0-9]$');

    _nothing = true;

    if (searchString.isEmpty || 
      !regex.hasMatch(searchString[0])) { return; }

    // Block?
    try {
      final blockInformation = await fetchFromGetBlock(getblockToken,
        'getblock', [searchString,1]);
      if (blockInformation['result'] != null) {
        setState(() {
          _showBlockResults = true;
          _nothing = false;
        });        
      } else {
        setState(() {
          _showBlockResults = false;
        }); 
      }
    } catch(e) {
      setState(() {
        _showBlockResults = false;
      }); 
    }
    // Tx?
    try {
      final txInformation = await fetchFromGetBlock(getblockToken,
        'getrawtransaction', [searchString,true]);
      if (txInformation['result'] != null) {
        setState(() {
          _showTxResults = true;
          _nothing = false;
        });        
      } else {
        setState(() {
          _showTxResults = false;
        });
      }
    } catch(e) {
      setState(() {
        _showTxResults = false;
      });
    }
    // Wallet?
    try {
      final walletInformation = await fetchFromBlockchainInfo(
        'multiaddr?active=$searchString');
      if (walletInformation['data'] != null) {
        setState(() {
          _showWalletResults = true;
          _nothing = false;
        });
      } else {
        setState(() {
          _showWalletResults = false;
        });
      }
    } catch(e) {
      setState(() {
        _showWalletResults = false;
      });
    }
    _firstSearch = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        actions: [
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
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Block, Tx, or Address',
              ),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height:40),
            // Search button
            ElevatedButton.icon(
              onPressed: _onSearch,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
            const SizedBox(height:40),
            // Show block results?
            if (_showBlockResults)
              ExplorerElementCard(
                elements: CardElements(
                  title: 'Block',
                  text: _searchController.text,
                ), 
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => BlockScreen(
                        blockHash: _searchController.text,
                      ),
                    )
                  );
                }
              ),
            // Show tx results?
            if (_showTxResults)
              ExplorerElementCard(
                elements: CardElements(
                  title: 'Tx',
                  text: _searchController.text,
                ), 
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => TxScreen(
                        txHash: _searchController.text,
                      ),
                    )
                  );
                }
              ),
            // Show wallet results?
            if (_showWalletResults)
              ExplorerElementCard(
                elements: CardElements(
                  title: 'Address',
                  text: _searchController.text,
                ), 
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => WalletScreen(
                        address: _searchController.text,
                      ),
                    )
                  );
                }
              ),
            // No results
            if (_nothing && _firstSearch)
              ExplorerElementCard(
                elements: CardElements(
                  title: 'Nothing found.',
                  text: _searchController.text,
                ), 
                onTap: null,
              ),
          ],
        ),
      ),
    );
  }
}