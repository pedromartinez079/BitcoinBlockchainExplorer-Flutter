import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bitcoin_blockchain_explorer/screens/settings.dart';
import 'package:bitcoin_blockchain_explorer/screens/search.dart';
import 'package:bitcoin_blockchain_explorer/widgets/card.dart';
import 'package:bitcoin_blockchain_explorer/screens/tx.dart';

import 'package:bitcoin_blockchain_explorer/services/getblock.dart';
import 'package:bitcoin_blockchain_explorer/providers/settings_provider.dart';
import 'package:intl/intl.dart';

class BlockScreen extends ConsumerStatefulWidget {
  const BlockScreen({
    super.key,
    required this.blockHash,
  });

  final String blockHash;

  @override
  ConsumerState<BlockScreen> createState() {
    return _BlockScreenState();
  }
}

class _BlockScreenState extends ConsumerState<BlockScreen> {
  Map<String, dynamic>? _blockInformation;
  bool _isBlockInformationFetched = false;
  bool _isLastBlock = false;
  Widget? _scaffoldBody;
  bool _showTxList = false;

  _getBlockInformation() async {
    // Get Block information
    try {
      final getblockToken = ref.watch(settingsProvider).token;
      final blockInformation = await fetchFromGetBlock(getblockToken,
        'getblock', [widget.blockHash,1]);

      setState(() {
        _blockInformation = blockInformation['result'];
        // Last Block?
        _isLastBlock = _blockInformation!['nextblockhash'] == null;
      });
      _isBlockInformationFetched = true;
    } catch(e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.cyanAccent,
          content: Text('${e.toString()}\nCheck GetBlock token!'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  // Previous Block button method
  _onPreviousBlock() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => BlockScreen(
          blockHash: _blockInformation!['previousblockhash'],
        ),
      )
    );
  }

  // Next Block button method
  _onNextBlock() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => BlockScreen(
          blockHash: _blockInformation!['nextblockhash'],
        ),
      )
    );
  }

  // Show Tx List button method
  _onShowTxList() {
    setState(() {
      _showTxList = !_showTxList;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget? blockInformation;
    DateTime? dateTime;
    String? formattedDate;

    if (!_isBlockInformationFetched) {
      _getBlockInformation();
    }

    if (_blockInformation != null) {
      dateTime = DateTime.fromMillisecondsSinceEpoch(_blockInformation!['time'] * 1000);
      formattedDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
      // Scaffold Body if Block information exists
      blockInformation = Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Block information
            ExplorerElementCard(
              onTap: null,
              elements: CardElements(
                title: 'Height: ${_blockInformation!['height'].toString()}',
                subtitle: 'hash: ${_blockInformation!['hash']}\n',
                textLines: [
                  'Confirmations: ${_blockInformation!['confirmations'].toString()}',
                  'Merkle Root: ${_blockInformation!['merkleroot']}',
                  'Time UTC: $formattedDate',
                  'nonce: ${_blockInformation!['nonce']}',
                  'Txs: ${_blockInformation!['nTx']}'
                ],
              ),
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                // Previous Block button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _blockInformation!['previousblockhash'] != null ?
                      _onPreviousBlock : null,
                    icon: Icon(Icons.arrow_back),
                    label: Text('Previous Block'),
                  ),
                ),
                SizedBox(width: 5,),
                // Next Block button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _blockInformation!['nextblockhash'] != null ?
                      _onNextBlock : null,
                    icon: Icon(Icons.arrow_forward),
                    label: Text('Next Block'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // List of Txs button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _blockInformation!['tx'] != null ?
                      _onShowTxList : null,
                    icon: Icon(Icons.list),
                    label: Text('List of Txs'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            // Show Tx list?
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
                  itemCount: _blockInformation!['tx'].length,
                  itemBuilder: (context, index) {
                    final hash = _blockInformation!['tx'][index];
                    return ListTile(
                      title: Text(hash),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => TxScreen(
                              txHash: hash,
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
        _scaffoldBody = blockInformation;
      });
    } else {
      // Scaffolf Body if Block information is not ready
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
        title: _isLastBlock ? Text('Last Block') : Text('Block'),
        actions: [
          // Update screen
          IconButton(
            onPressed: () {
              setState(() {
                _isBlockInformationFetched = false;
                _blockInformation = null;
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